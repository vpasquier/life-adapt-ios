import json


def handler(event, context):
    try:
        accelerometer_data = json.loads(event["body"])
        accelerometer_x = accelerometer_data.get("accelerometerX", [])
        accelerometer_y = accelerometer_data.get("accelerometerY", [])
        accelerometer_z = accelerometer_data.get("accelerometerZ", [])
        response_data = {
            "accelerometerX": accelerometer_x,
            "accelerometerY": accelerometer_y,
            "accelerometerZ": accelerometer_z,
        }
        return {"statusCode": 200, "body": json.dumps(response_data)}
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error processing request: {str(e)}"),
        }
