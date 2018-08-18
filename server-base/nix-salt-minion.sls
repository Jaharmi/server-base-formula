service-salt:
  service.running:
    - name: salt-minion
    - enable: true

/etc/salt/grains:
  file.managed:
    - user: root
    - mode: 0660
