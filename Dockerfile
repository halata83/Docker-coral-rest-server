# Dockerfile pro sestaveni image pro google coral server s modelem
#sestavte pomoci: sudo docker build -t coral .
#upload do docker hub: sudo docker tag coral halilucky/coral:EfficientDet-Lite3
#                      sudo docker login
#                      sudo docker push halilucky/coral:EfficientDet-Lite3
#
#spustit contejner: sudo docker run --restart=always --detach --name coral -p 5000:5000 --device /dev/bus/usb:/dev/bus/usb halilucky/coral:EfficientDet-Lite3
#
#test: curl -X POST -F image=@images/test-image3.jpg 'http://localhost:5000/v1/vision/detection'
ARG BUILD_FROM="amd64/ubuntu:20.04"
FROM ${BUILD_FROM}

WORKDIR /tmp

RUN apt-get update && apt-get install -y gnupg curl
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list
RUN echo "deb https://packages.cloud.google.com/apt coral-cloud-stable main" | tee /etc/apt/sources.list.d/coral-cloud.list

RUN apt-get update && apt-get install -y python3 wget unzip python3-pip
RUN apt-get -y install python3-edgetpu libedgetpu1-legacy-std

# install the APP
RUN cd /tmp && \
    wget "https://github.com/robmarkcole/coral-pi-rest-server/archive/refs/tags/v1.0.zip" -O /tmp/server.zip && \
    unzip /tmp/server.zip && \
    rm -f /tmp/server.zip && \
    mv coral-pi-rest-server-1.0 /app



WORKDIR /app
RUN  pip3 install --no-cache-dir -r requirements.txt

# Temporarily using my own code until https://github.com/robmarkcole/coral-pi-rest-server/issues/67 is resolved
RUN wget https://raw.githubusercontent.com/grinco/coral-pi-rest-server/v1.0/coral-app.py -O /app/coral-app.py

COPY . /app
RUN chmod a+x /app/run.sh
RUN chmod 777 /app/run.sh
EXPOSE 5000

CMD [ "/app/run.sh" ]
