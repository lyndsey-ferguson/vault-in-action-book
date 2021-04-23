# https://github.com/osixia/docker-openldap

FROM osixia/openldap

ENV LDAP_ORGANISATION="Magic Dollar"
ENV LDAP_DOMAIN="magicdollar.com"

COPY bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif
