category-labs-apt-source:
  file.managed:
    - name: /etc/apt/sources.list.d/category-labs.sources
    - contents: |
        Types: deb
        URIs: https://pkg.category.xyz/
        Suites: noble
        Components: main
        Signed-By: /etc/apt/keyrings/category-labs.gpg
    - user: root
    - group: root
    - mode: '0644'

category-labs-auth:
  file.managed:
    - name: /etc/apt/auth.conf.d/category-labs.conf
    - contents: |
        machine https://pkg.category.xyz/
        login pkgs
        password af078cc4157b45f29e279879840fd260
    - user: root
    - group: root
    - mode: '0600'
