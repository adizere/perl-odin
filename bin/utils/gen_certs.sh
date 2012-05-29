#!/bin/sh

##
# Certificate authority and Server certificates generation

usage() {
    echo "Usage: $0 TARGET_DIRECTORY";
}

CA_DIR="ca";
SERVER_DIR="server";

CERT_NAME="sample.crt";
PK_NAME="sample.key";
REQ_NAME="request.csr"

DAYS=9000


if [ ! $1 ] ; then
  usage;
  exit;
fi

target=$1;


# make directories..
if [ ! "$(ls -Al $target | grep $CA_DIR)" ] ; then
    mkdir "$target/$CA_DIR"
fi

if [ ! "$(ls -Al $target | grep $SERVER_DIR)" ] ; then
    mkdir "$target/$SERVER_DIR"
fi


# Your Certificate Authority
openssl genrsa -out "$target/$CA_DIR/$PK_NAME" 2048
openssl req -new -x509 -nodes -days $DAYS -key "$target/$CA_DIR/$PK_NAME" -out "$target/$CA_DIR/$CERT_NAME"


# Server's cerificate
openssl req -new -newkey rsa:2048 -nodes -keyout "$target/$SERVER_DIR/$PK_NAME" -out "$target/$SERVER_DIR/$REQ_NAME"
openssl x509 -req -days $DAYS -CA "$target/$CA_DIR/$CERT_NAME" -CAkey "$target/$CA_DIR/$PK_NAME" -CAcreateserial -in "$target/$SERVER_DIR/$REQ_NAME" -out "$target/$SERVER_DIR/$CERT_NAME"


chmod -R 400 "$target/$CA_DIR";
chmod -R 400 "$target/$SERVER_DIR";
