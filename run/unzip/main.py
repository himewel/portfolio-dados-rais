import os
import re
from io import BytesIO

from flask import Flask, request, jsonify
from google.cloud.storage import Client
from py7zr import SevenZipFile

app = Flask(__name__)


def from_gcs(bucket_name, blob_name):
    storage_client = Client()
    bucket = storage_client.bucket(bucket_name)

    blob = bucket.blob(blob_name)
    contents = blob.download_as_string()

    buffer = BytesIO()
    buffer.write(contents)
    buffer.seek(0)
    return buffer


def to_gcs(path, buffer):
    storage_client = Client()
    bucket_name = "raw-270822"
    bucket = storage_client.bucket(bucket_name)

    blob = bucket.blob(path)
    blob.upload_from_file(buffer)
    return f"gs://{bucket_name}{path}"


@app.route("/", methods=["POST"])
def receive_event():
    data = request.json
    body = data["message"]
    print(f"Receiving new request: {data}")
    attributes = body["attributes"]

    # do nothing when not a .7z file
    if not attributes["objectId"].endswith("7z"):
        print("Nothing to do")
        return "Nothing to do"

    # extract only csv and txt files
    pattern = re.compile(r"^.*(\.txt|\.csv)$")
    # reading file from GCS
    buffer = from_gcs(attributes["bucketId"], attributes["objectId"])

    path_list = []
    with SevenZipFile(buffer) as zip:
        # check targets matching pattern
        targets = [f for f in zip.getnames() if pattern.match(f)]
        # iterate by each file of the 7z
        for fname, stream in zip.read(targets).items():
            directory = fname[:-10]
            date = fname[-10:]

            print(f"Uploading new file: {directory}/{date}")
            path = to_gcs(f"{directory}/{date}", stream)
            path_list.append(path)

    return jsonify(path_list)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
