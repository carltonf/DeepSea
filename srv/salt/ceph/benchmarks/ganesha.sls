
prep master:
  salt.state:
    - tgt: {{ salt['pillar.get']('master_minion') }}
    - sls:
      - ceph.ganesha.benchmarks.prepare_master

{% set ganesha_server = salt.saltutil.runner('select.minions', cluster='ceph', roles='ganesha')[0] %}
prep clients:
  salt.state:
    - tgt: "I@roles:client-nfs"
    - tgt_type: compound
    - sls: ceph.ganesha.benchmarks.prepare_clients
    - pillar:
        'ganesha-server': {{ ganesha_server}}

one subdir:
  salt.state:
    - tgt: {{  salt.saltutil.runner('select.one_minion', cluster='ceph', roles='client-nfs') }}
    - sls:
      - ceph.ganesha.benchmarks.working_subdir

run fio:
  salt.runner:
    - name: benchmark.ganesha
    - work_dir: {{ salt['pillar.get']('benchmark:work-directory') }}
    - log_dir: {{ salt['pillar.get']('benchmark:log-file-directory') }}
    - job_dir: {{ salt['pillar.get']('benchmark:job-file-directory') }}
    - default_collection: {{ salt['pillar.get']('benchmark:default-collection') }}
    - client_glob : "I@roles:client-nfs"

clean subdir:
  salt.state:
    - tgt: {{  salt.saltutil.runner('select.one_minion', cluster='ceph', roles='client-nfs') }}
    - sls:
      - ceph.ganesha.benchmarks.cleanup_working_subdir

cleanup fio:
  salt.state:
    - tgt: "I@roles:client-nfs"
    - tgt_type: compound
    - sls:
      - ceph.ganesha.benchmarks.cleanup
