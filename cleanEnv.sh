#!/bin/bash

cat /var/log/snortvm/snort.log >> /var/log/snortvm/snort.safe
rm -rf /var/log/snortvm/snort.log
