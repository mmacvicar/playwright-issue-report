TARGET_DOMAIN?=fake.example.com
REAL_DOMAIN?=httpbin.org
PORT=8888

.PHONY: run request request-no-proxy

check-etc-hosts:
	@grep -q "1\.2\.3\.4[[:space:]]\+$(TARGET_DOMAIN)" /etc/hosts || (echo "Define ${TARGET_DOMAIN} in /etc/hosts it to ensure it is unreachable but resolves (i.e 1.2.3.4 $(TARGET_DOMAIN)). You can use make add-etc-hosts with sudo as well" && exit 1)

add-etc-hosts:
	@echo "1.2.3.4 $(TARGET_DOMAIN)" >> /etc/hosts

run-proxy:	
	@echo "$(shell dig +short ${REAL_DOMAIN} | head -n1) $(TARGET_DOMAIN)" > hosts
	@docker rm -f tinyproxy > /dev/null 2>&1
	@echo "Starting tinyproxy..."
	@docker run -d --name tinyproxy -p $(PORT):$(PORT) -v ./hosts:/etc/hosts vimagick/tinyproxy

run: run-proxy deps
	@node main.js

request:
	curl -k -I --proxy "localhost:$(PORT)" https://$(TARGET_DOMAIN)

request-no-proxy:
	curl -k -I https://$(TARGET_DOMAIN)

certs/client.pfx:
	@mkdir -p certs
	@openssl genpkey -algorithm RSA -out certs/client.key -pkeyopt rsa_keygen_bits:2048
	@openssl req -new -key certs/client.key -out certs/client.csr -subj "/C=US/ST=California/L=San Francisco/O=MyOrg/OU=MyOrgUnit/CN=client"
	@openssl x509 -req -in certs/client.csr -signkey certs/client.key -out certs/client.crt -days 365
	@openssl pkcs12 -export -out certs/client.pfx -inkey certs/client.key -in certs/client.crt -password pass:password

deps: certs/client.pfx
	@npm install playwright@1.50.1