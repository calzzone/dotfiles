### create

github_create() {
    git config --global user.name "Alex Istrate"
    git config --global user.email "calzzon3@gmail.com"
    git config --global hub.protocol https


    echo "# ${PWD##*/}" >> README.md
    git init

    # git status
    git add . && git commit -m "First commit"
    git branch master_backup

    hub create
    # git remote -v
    # git remote set-url origin https://github.com/calzzone/Marcel-Narita.git
    git push -u origin master

    git config --global credential.helper cache
    git config --global credential.helper 'cache --timeout=3600'
}


### update

github_update() {
    git config --global user.name "Alex Istrate"
    git config --global user.email "calzzon3@gmail.com"
    git config --global hub.protocol https

    git add . && git commit -m "updates: $@"
    git push -u origin master
}
