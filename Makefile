LOGDIR=logs
NUM_OF_SERVERS=20

all:
	@echo "make build -- build docker images"
	@echo "make run-with-scollector -- run webserver containers incl. scollector"
	@echo "make run-without-scollector -- run webserver containers without starting scollector"
	@echo "make run-bosun-server -- run bosun server container"
	@echo "make run-prometheus-server -- run prometheus server container"
	@echo "make run-container-exporter -- run container-exporter, to expose docker metrics to prometheus server"
	@echo "make run-local-scollector -- run scollector inside vagrant box"
	@echo "make demo -- execute demo"
	@echo "make stop -- stop and remove all containers"

$(LOGDIR):
	@mkdir -p $@

build:
	@docker build --no-cache --force-rm -t lukaspustina/docker_demo_python python
	@docker build --no-cache --force-rm -t lukaspustina/docker_demo_webserver webserver
	@docker build --no-cache --force-rm -t christianzunker/docker_demo_webserver_scollector webserver_scollector
	@docker build --no-cache --force-rm -t christianzunker/docker_demo_prometheus prometheus
	@docker images

run-bosun-server:
	@docker run -d -p 8070:8070 stackexchange/bosun

run-prometheus-server:
	@docker run -d -p 9091:9090 --name=prometheus-server christianzunker/docker_demo_prometheus
	@docker exec -dt prometheus-server "/go/src/github.com/prometheus/prometheus/prometheus -logtostderr -config.file=/prometheus.conf -web.console.libraries=/go/src/github.com/prometheus/prometheus/console_libraries -web.console.templates=/go/src/github.com/prometheus/prometheus/consoles"

run-container-exporter:
	@docker run -d -p 8080:8080 -v /sys/fs/cgroup:/cgroup -v /var/run/docker.sock:/var/run/docker.sock prom/container-exporter

run-local-scollector:
	@sudo nohup /opt/scollector/scollector -h localhost:8070 &

run-with-scollector: $(LOGDIR)
	@echo "+++ Starting containers +++"
	@for i in `seq 1 $(NUM_OF_SERVERS)`; do \
		name=webserver-$$i; \
		container_id=$$(docker run -d --cidfile=$</webserver-$$i.cid --name=$$name --hostname=$$name -v `pwd`/$<:/logs christianzunker/docker_demo_webserver_scollector:latest /opt/webserver/run.sh /logs) ; \
		docker exec -dt $$name nohup /opt/scollector/scollector -h 172.17.42.1:8070 \
		docker ps -l | tail -n +2; \
	done
	@sleep 1

run-without-scollector: $(LOGDIR)
	@echo "+++ Starting containers +++"
	@for i in `seq 1 $(NUM_OF_SERVERS)`; do \
		name=webserver-$$i; \
		container_id=$$(docker run -d --cidfile=$</webserver-$$i.cid --name=$$name --hostname=$$name -v `pwd`/$<:/logs christianzunker/docker_demo_webserver_scollector:latest /opt/webserver/run.sh /logs) ; \
		docker ps -l | tail -n +2; \
	done
	@sleep 1

demo:
	@echo "+++ Starting demo +++"
	@for i in $$(docker ps -q | xargs docker inspect -f '{{ .NetworkSettings.IPAddress }}'); do \
		curl http://$$i:8080; \
	 done


stop: $(LOGDIR)
	-@docker ps | grep christianzunker/docker_demo_webserver_scollector | awk '{ print $$1 }' | xargs docker kill > /dev/null
	-@docker ps -a | grep christianzunker/docker_demo_webserver_scollector | awk '{ print $$1 }' | xargs docker rm > /dev/null
	-@rm $</*.cid

clean: clean-logs clean-images

clean-logs:
	-@rm -rf $(LOGDIR)

clean-images:
	-@docker images -q | xargs docker rmi

