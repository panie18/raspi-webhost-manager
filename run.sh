#!/bin/bash
cd /opt/raspi-webhost-manager
export FLASK_APP=app
flask run --host=0.0.0.0 --port=5000
