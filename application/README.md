# Flask color app

This is a Demo Flask application that chan


## Endpoints

| Endpoint       |                  Description               |
| -------------- | ------------------------------------------ |
| `/`            | Start page that changes background color depends on `BG_COLOR` env variable         |
| `/test_db`     | Page with form to post a message to MongoDB |
| `/color`       | API to get current color, timestamp and system information |
| `/issue`       | API to get status of issue |
| `/db_message`  | API to get messages from MongoDB

## Environment variables

| Variable       | Default Value |                 Description                 |
| -------------- | ------------- | ------------------------------------------- |
| BG_COLOR       | `white`       | Background color for start page and API. List of colors is located at [link](color_list.txt)    |
| MONGO_USERNAME | `root`        | Username for MongoDB connections            |
| MONGO_PASSWORD | `example`     | Username's passwrod for MongoDB connections |
| MONGO_HOST     | `localhost`   | MongoDB's hostname                          |
| MONGO_PORT     | `27017`       | MongoDB's password                          |

## Supported colors

List of supported colors is located at [link](color_list.txt)
