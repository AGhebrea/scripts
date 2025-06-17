if [ -d /tmp/test ]; then
    rm -r /tmp/test
fi
if [ -f /tmp/test ]; then
    rm -r /tmp/test
fi

mkdir /tmp/test
cd /tmp/test