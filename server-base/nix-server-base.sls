# Configure for RHEL based systems
{% if salt.grains.get('os_family') == 'RedHat' %}

package-install-epel-server-base:
  pkg.installed:
    - pkgs:
      - epel-release             # Base install

package-install-rhel-server-base:
  pkg.installed:
    - pkgs:
      - yum-utils                # Base install
      - deltarpm                 # Base install
      - policycoreutils-python   # Base install
      - vim-enhanced             # Base install
    - refresh: True

{% elif salt.grains.get('os_family') == 'Debian' %}

package-install-deb-server-base:
  pkg.installed:
    - pkgs:
      - apparmor                 # Base install
      - apparmor-utils           # Base install
      - vim-nox                  # Base install
      - iptables-persistent      # Base install
    - refresh: True

{% endif %}

package-install-nix-server-base:
  pkg.installed:
    - pkgs:
      - ca-certificates          # Base install
      - rsyslog                  # Base install
      - wget                     # Base install
      - curl                     # Base install
      - mlocate                  # Base install
      - git                      # Base install
      - sudo                     # Base install
      - tree                     # Base install
      - lsof                     # Base install
      - tmux                     # Base install
      - htop                     # Base install
      - bash-completion          # Base install
      - colordiff                # Base install
    - refresh: True

colordiff-default-colors:
  file.replace:
    - name: /etc/colordiffrc
    - pattern: |
        plain=black
        newtext=darkblue
        oldtext=darkred
        diffstuff=darkgreen
        cvsstuff=darkwhite
    - repl: |
        plain=black
        newtext=blue
        oldtext=red
        diffstuff=darkgreen
        cvsstuff=darkwhite
    - unless: grep 'oldtext=red' /etc/colordiffrc

sudoers-disable-requiretty:
  file.replace:
    - name: /etc/sudoers
    - pattern: |
        Defaults\s+requiretty
    - repl: |
        #Defaults    requiretty
    - unless: grep '#Defaults    requiretty' /etc/sudoers

sudoers-enable-wheel:
  file.replace:
    - name: /etc/sudoers
    - pattern: |
        #.?%wheel\s+ALL=\(ALL\)\s+ALL
    - repl: |
        %wheel  ALL=(ALL)       ALL

{% if salt.grains.get('os_family') == 'RedHat' %}
  {% set release_file = 'redhat-release' %}
{% elif salt.grains.get('os_family') == 'Debian' %}
  {% set release_file = 'debian_version' %}
{% endif %}

command-cat-/etc/motd:
  cmd.run:
    - name: cat /etc/{{ release_file }} > /etc/motd
    - unless: cmp /etc/{{ release_file }} /etc/motd

/etc/issue:
  file.managed:
    - source: salt://server-base/files/issue
    - user: root
    - group: root
    - mode: '0644'

/etc/issue.net:
  file.managed:
    - source: salt://server-base/files/issue.net
    - user: root
    - group: root
    - mode: '0644'

{% if salt['grains.get']('init') == 'systemd' %}
/etc/systemd/system/ctrl-alt-del.target:
  file.symlink:
    - target: /dev/null    
{% elif salt['grains.get']('init') == 'upstart' %}
/etc/init/control-alt-delete.override:
  file.managed:
    - contents:
      - "# control-alt-delete handling - managed by Salt"
      - ""
      - start on control-alt-delete
      - exec /usr/bin/logger -p authpriv.notice -t init "Ctrl-Alt-Del was pressed and ignored"
{% endif %}
