#!/bin/bash
PROJECT_NAME=$1
OPERATORS_FILE="/home/fff37/scripts/operators"
WORKDIR="/projects"
PROJECT_DIR="$WORKDIR/$PROJECT_NAME"
#rm -rf /projects/delete01/
function install () {
  apt install tree pwgen -y
}

function report (){
  echo abcde
}

function access(){
echo "access"
users=$@


}

function arquivar(){
  if [ -z "$PROJECT_NAME" ]; then
    echo "Erro: Nome do projeto não especificado"
    echo "Uso: $0 <nome_do_projeto> --arquivar"
    exit 1
  fi

  ARCHIVE_DATE=$(date +%Y-%m-%d)
  ARCHIVE_DIR="/projects/archived/$ARCHIVE_DATE"

  echo "[+] Verificando se o vault existe..."
  if [ ! -d "$PROJECT_DIR/vault" ]; then
    echo "Erro: Vault $PROJECT_DIR/vault não encontrado ou já foi arquivado"
    exit 1
  fi
  echo "Vault encontrado: $PROJECT_DIR/vault"

  echo "[+] Criando diretório de arquivo..."
  mkdir -p "$ARCHIVE_DIR"

  echo "[+] Movendo vault para arquivo..."
  mv "$PROJECT_DIR/vault" "$ARCHIVE_DIR/${PROJECT_NAME}_vault"

  echo "[+] Compactando vault arquivado..."
  cd "$ARCHIVE_DIR" && tar -czf "${PROJECT_NAME}_vault_${ARCHIVE_DATE}.tar.gz" "${PROJECT_NAME}_vault" && rm -rf "${PROJECT_NAME}_vault"

  echo "[+] Movendo projeto para /root..."
  mv "$PROJECT_DIR" /root/

  echo "[+] Definindo permissões (read-only)..."
  chmod 400 -R "/root/$PROJECT_NAME"

  echo "[+] Vault $PROJECT_NAME arquivado com sucesso!"
  echo "Arquivo: $ARCHIVE_DIR/${PROJECT_NAME}_vault_${ARCHIVE_DATE}.tar.gz"
  echo "Backup: /root/$PROJECT_NAME"
}

# Verifica se foi passado --arquivar como segundo argumento
if [ "$2" == "--arquivar" ]; then
  arquivar
  exit 0
fi

# echo cleaning
# rm -rf $PROJECT_DIR
# userdel -f -r testehandler
# groupdel testeproject
# groupdel operators

echo "[+] Creating the directory structure"
if [ -e $WORKDIR ]
then
  echo "$WORKDIR FOUND"
else
  echo "$WORKDIR missing, creating..."
  mkdir $WORKDIR
fi

if [ -e $PROJECT_DIR ]
then echo "$PROJECT_DIR FOUND"
  echo "Manual assessment is required, exiting..."
  exit
else
  echo "$PROJET_DIR  missing, creating..."
  mkdir $PROJECT_DIR
fi

#mkdir -p $PROJECT_DIR/vault
mkdir -p $PROJECT_DIR/targets # targets/host/dumps targets/host/exploits target/host/recon
mkdir -p $PROJECT_DIR/screenshots
mkdir -p $PROJECT_DIR/logs
mkdir -p $PROJECT_DIR/operators
#HOME="$PROJECT_DIR/op/"
# git clone project template

#GITURL="git@github.com:Unidade37/project-template.git" #  $PROJECT_DIR/vault
#git clone git@github.com:Unidade37/obsidian-vault-u37.git

#$PROJECT_DIR/vault
## new template 2025 - foppa 21-09-2025
cp -rp /root/template-2025 $PROJECT_DIR/vault

#git clone git@github.com:Unidade37/project-template.git  $PROJECT_DIR/vault
#git clone git@github.com:Unidade37/project-template.git  $PROJECT_DIR/vault
# Create a luks block
# open
# create the project FHS
# set the team members permissions

  check=$(getent group operators 1>/dev/null ; echo $?)
  if [ $check -eq 0 ]; then
     echo "group operators already exist"
  else
     echo "creating group operators"
     groupadd operators
  fi

#IFS=", "
for op in $OPERATORS; do echo $op ;done
 echo $OPERATORS_FILE
for operator in $(cat $OPERATORS_FILE  | tr -d '"' | cut -d "," -f 1,-9 );do
  echo $operator
  check=$(getent group $PROJECT_NAME 1>/dev/null ; echo $?)
  if [ $check -eq 0 ]; then
     echo "group $PROJECT_NAME already exist"
  else
     echo "creating group $PROJECT_NAME"
     groupadd $PROJECT_NAME
  fi
  check=$(getent passwd $operator 1>/dev/null ; echo $?)
  if [ $check -eq 0 ]; then
     echo "user $operator already exist, adding to group $PROJECT_NAME"
     usermod -aG $PROJECT_NAME $operator
  else
     echo "creating user $operator"
     useradd -c "Usuário de Operação" -g operators -G $PROJECT_NAME  -s /bin/bash -m  -d /home/$operator  $operator
     cp /home/fff37/scripts/Obsidian.desktop /home/$operator/Desktop/Obsidian.desktop
     chown $operator:operators /home/$operator/Desktop/Obsidian.desktop
     ln -s /projects/$PROJECT_NAME  /home/$operator/Desktop/$PROJECT_NAME
     #useradd -c "Usuário de Operação" -g operators -G $PROJECT_NAME  -s /bin/sh -d $HOME/$operator $operator
     #useradd -c "Usuário de Operação" -g operators -G $PROJECT_NAME -M -s /bin/sh -d /projects $operator
     password=$(pwgen -sy 16 -N 1)
     echo "Seting password for user"
     echo $operator:$password | chpasswd
     echo "DONE: $operator:$password"
     password="cleaninnnggggg"
  fi
#  USERLIST="$USERLIST $operator"
#  mkdir -p $PROJECT_DIR/operators/$operator
#  cp -rp $PROJECT_DIR/vault/.obsidian "$PROJECT_DIR/vault/.$operator"
done


# TODO - Copiar o .obsidian p/ cada operador
tree -R -d  $PROJECT_DIR
echo "[-] Updating the $PROJECT_DIR ACL to group $PROJECT_NAME"
#setfacl -R -d  g:$PROJECT_NAME:rwx $PROJECT_DIR/
setfacl -d -R -m g:$PROJECT_NAME:rwx $PROJECT_DIR/

echo "Changing the $PROJECT_DIR ownership to root and group to $PROJECT_NAME"
chown -R root:$PROJECT_NAME $PROJECT_DIR
echo "Changing the directory $PROJECT_DIR permissions to 760"
chmod g+ws -R $PROJECT_DIR
echo $USERLIST
#access $USERLIST
getent passwd $USERLIST
getent group $PROJECT_NAME

#echo "Use the following command to access the SSFHS:"
#echo "net use X: \\sshfs\fff37@10.0.0.3"
echo "Configuration for Obsidian in Kasm: /share/$PROJECT_NAME/vault/"
