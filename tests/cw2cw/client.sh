
. vars
DIR=$(cd "$(dirname "$0")"; pwd)
$CW $TESTS/altchannels.cw ${DIR}/shared/ ${DIR}/client/ -cp 10001

#you can connect to the client with:  iosh -p 10001  and to the server with just iosh
#you can sample the client with sampler --cw-port 10001 and the server as normal
