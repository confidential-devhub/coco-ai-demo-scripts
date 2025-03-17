#! /bin/bash

set -e

SRC=$1
DEST=$2
MODEL_F=${DEST}/1
MODEL_FILE=$MODEL_F/model.onnx
MODEL_FILE_ENC=$MODEL_FILE.enc

KEY_FOLDER=keys
KEY_FILE=$KEY_FOLDER/key.bin

echo "SRC $SRC"
echo "DEST $DEST"
echo "MODEL_F $MODEL_F"
echo "MODEL_FILE_ENC $MODEL_FILE_ENC"
echo ""

echo "#######################################"
./download-model $SRC $DEST
echo "#######################################"
echo ""

KBS_PATH=${KBS_PATH:-"fraud-detection/key.bin"}
echo "KBS_PATH: $KBS_PATH"
echo ""

# export S3_VERIFY_SSL=0

echo "Models downloaded:"
ls -R $DEST
echo ""

echo "Current folder:"
ls -R $KEY_FOLDER
echo ""

echo "Downloading the key:"
# curl -L http://127.0.0.1:8006/cdh/resource/default/$KBS_PATH -o $KEY_FILE
curl -L https://people.redhat.com/eesposit/key.bin -o $KEY_FILE

ls -R $KEY_FOLDER
echo ""

echo "Decrypting model:"
openssl enc -d -aes-256-cbc -pbkdf2 -kfile $KEY_FILE -in $MODEL_FILE_ENC -out $MODEL_FILE

ls -R $DEST
echo ""
