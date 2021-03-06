
prevent empty rendering:
  test.nop:
    - name: skip

{% for host in salt.saltutil.runner('select.minions', cluster='ceph', roles='mds', host=True) %}
{% set client = "mds." + host %}
{% set keyring_file = salt['keyring.file']('mds', host)  %}

auth {{ keyring_file }}:
  cmd.run:
    - name: "ceph auth add {{ client }} -i {{ keyring_file }}"

{% endfor %}


