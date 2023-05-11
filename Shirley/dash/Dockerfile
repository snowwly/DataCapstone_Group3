FROM python:3.8-slim-buster

RUN mkdir /app
WORKDIR /app
ADD requirements.txt /app/
RUN pip install -r requirements.txt
RUN pip install dash --upgrade
ADD . /app/

ENTRYPOINT [ "python" ]
CMD ["dashtutorial.py"]