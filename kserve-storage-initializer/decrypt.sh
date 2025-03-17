#! /bin/bash

set -e
# variables provided via ClusterStorageContainer
MODEL_ENCRYPTED=${MODEL_ENCRYPTED:-true} # wether to decrypt the model or not
MODEL_DECRYPTION_KEY=${MODEL_DECRYPTION_KEY:-"fraud-detection/key.bin"} # path to the secret/file in Trustee
MODEL_NAME=${MODEL_NAME:-"model"} # name of the model, without format
MODEL_FORMAT=${MODEL_FORMAT:-"onnx"} # format of the model

SRC=$1
DEST=$2
MODEL_F=${DEST}/1
MODEL_FILE=$MODEL_F/$MODEL_NAME.$MODEL_FORMAT
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

if ! $MODEL_ENCRYPTED 2> /dev/null; then
    exit 0
fi

echo "MODEL_DECRYPTION_KEY: $MODEL_DECRYPTION_KEY"
echo ""

# export S3_VERIFY_SSL=0

echo "Models downloaded:"
ls -R $DEST
echo ""

echo "Current folder:"
ls -R $KEY_FOLDER
echo ""

echo "Downloading the key:"
curl -L http://127.0.0.1:8006/cdh/resource/default/$MODEL_DECRYPTION_KEY -o $KEY_FILE

ls -R $KEY_FOLDER
echo ""

echo "Decrypting model:"
openssl enc -d -aes-256-cbc -pbkdf2 -kfile $KEY_FILE -in $MODEL_FILE_ENC -out $MODEL_FILE
echo "Decription completed!"
echo ""

ls -R $DEST
echo ""
