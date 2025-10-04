docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1
docker container restart 513d4d259992
docker inspect --format='{{.NetworkSettings.IPAddress}}' 49389c8c06ce 513d4d259992
