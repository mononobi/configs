FROM IMAGE:VERSION

RUN mkdir /opt/app

RUN apt-get update && apt-get install -y python3-dev gcc && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /opt/app/requirements.txt

WORKDIR /opt/app
ENV PYTHONPATH /opt/app

RUN pip3 install -r requirements.txt

COPY . /opt/app

ENTRYPOINT ["sh"]
CMD ["run.sh"]
