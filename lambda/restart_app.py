import json
import os
import boto3

ssm = boto3.client("ssm")
INSTANCE_ID = os.environ["INSTANCE_ID"]
TARGET_ALARM = "self-healing-infra-app-down"


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
        print("Sent restart command:", response["Command"]["CommandId"])

    return {"ok": True}
