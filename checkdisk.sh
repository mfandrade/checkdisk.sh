#!/bin/bash

# Percentual de uso do disco acima do qual o script emitirá avisos
THRESHOLD=85

# Endereços do destinatário e remetente
TO='diego.valdez@trt8.jus.br marcelo.andrade@trt8.jus.br'
FROM='pje.producao.root@trt8.jus.br'

# Não edite abaixo desta linha a menos que saiba o que está fazendo
# -----------------------------------------------------------------------
USEDSPACE=$(df -Ph / | grep / | awk '{ print $5 }' | tr -d '%')
SUBJECT='ATENCAO: '"$USEDSPACE% OCUPADO NO / DE $(hostname)"

if [[ $USEDSPACE -ge $THRESHOLD ]]; then

        echo $SUBJECT

        # Lista os 5 maiores arquivos do disco
        qtd=5
        BIGFILES=$(mktemp)
        echo "Os $qtd maiores arquivos em disco sao:" > $BIGFILES
        find / -type f -size +51200k 2>/dev/null \
                -exec ls -lh {} \; \
                | awk '{ print $5 "\t" $9 }' \
                | sort -rh \
                | head -n +$qtd >> $BIGFILES

        if [[ ! -f $HOME/.mailrc ]]; then
                echo "set smtp=smtp://correio.trt8.jus.br:25" > $HOME/.mailrc
        fi

        mail -r "$FROM" -s "$SUBJECT" "$TO" < $BIGFILES && echo "Aviso enviado."
fi
