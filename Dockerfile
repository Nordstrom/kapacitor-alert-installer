FROM kapacitor:1.1.1

COPY kapacitorAlertLoader.sh /kapacitorAlertLoader.sh
ENTRYPOINT ["/kapacitorAlertLoader.sh"]
