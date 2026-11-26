import json
import os
import time

import boto3
from botocore.exceptions import ClientError

ssm = boto3.client("ssm")
sns = boto3.client("sns")

INSTANCE_ID = os.environ["INSTANCE_ID"]
RECOVERY_TOPIC_ARN = os.environ["RECOVERY_TOPIC_ARN"]
TARGET_ALARM = "self-healing-infra-app-down"


def wait_for_result(command_id, attempts=10):
    for _ in range(attempts):
        time.sleep(3)
        try:
            inv = ssm.get_command_invocation(
                CommandId=command_id, InstanceId=INSTANCE_ID
            )
        except ClientError as err:
            if err.response["Error"]["Code"] == "InvocationDoesNotExist":
                continue
            raise
        if inv["Status"] not in ("Pending", "InProgress", "Delayed"):
            return inv
    return None


def handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["Sns"]["Message"])
        alarm = message.get("AlarmName")
        state = message.get("NewStateValue")
        print(f"Alarm {alarm} changed to {state}")

        if state != "ALARM" or alarm != TARGET_ALARM:
            print("Not the app-down ALARM, nothing to do")
            continue

        response = ssm.send_command(
            InstanceIds=[INSTANCE_ID],
            DocumentName="AWS-RunShellScript",
            Parameters={
                "commands": [
                    "systemctl restart demo-app",
                    "sleep 3",
                    "systemctl is-active demo-app",
                    "curl -sf http://127.0.0.1:5000/health",
                ]
            },
            Comment="self-healing: restart demo-app",
        )
        command_id = response["Command"]["CommandId"]
        print("Sent restart command:", command_id)

        result = wait_for_result(command_id)
        status = result["Status"] if result else "Unknown"
        output = (result or {}).get("StandardOutputContent", "")
        print("Recovery status:", status)

        ok = status == "Success"
        sns.publish(
            TopicArn=RECOVERY_TOPIC_ARN,
            Subject=f"Recovery {'SUCCEEDED' if ok else 'FAILED'}: demo-app",
            Message=(
                f"Alarm: {alarm}\nInstance: {INSTANCE_ID}\n"
                f"Command: {command_id}\nStatus: {status}\n\n{output}"
            ),
        )

    return {"ok": True}
