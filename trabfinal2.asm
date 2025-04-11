.data
# Pritns menu inciail
str_titulo:      .asciiz "\n===== SISTEMA BANCARIO =====\n"
str_criar_conta: .asciiz "1. Criar Conta\n"
str_login:       .asciiz "2. Login\n"
str_admin:       .asciiz "3. Admin\n"
str_sair:        .asciiz "4. Sair\n"
str_opcao:       .asciiz "Escolha uma opcao: "

# Prints menu usuario
str_menu_usuario:    .asciiz "\n===== MENU USUARIO =====\n"
str_ver_saldo:       .asciiz "1. Ver Saldo\n"
str_deposito:        .asciiz "2. Realizar Deposito\n"
str_saque:           .asciiz "3. Realizar Saque\n"
str_transferencia:   .asciiz "4. Realizar Transferencia\n"
str_logout:          .asciiz "5. Logout\n"
transferencia: .asciiz "\nValor da transferencia: "
para: .asciiz "\nConta de Destino: "
arquivo: .asciiz "nota.txt"
# Pritns menu admin
str_menu_admin:      .asciiz "\n===== MENU ADMIN =====\n"
str_listar_contas:   .asciiz "1. Listar Todas as Contas\n"
str_logout_admin:    .asciiz "2. Logout\n"
str_conta_info:      .asciiz "\nConta #"
str_separador:       .asciiz ": "
str_saldo_info:      .asciiz "  |  Saldo: R$ "

# Prints OP
str_nome:        .asciiz "Nome: "
str_senha:       .asciiz "Senha (4 digitos): "
str_saldo:       .asciiz "Saldo: R$ "
str_valor:       .asciiz "Valor: R$ "
str_destino:     .asciiz "Conta de destino: "
str_sucesso:     .asciiz "Operacao realizada com sucesso!\n"
str_falha:       .asciiz "Falha na operacao.\n"
str_limite:      .asciiz "Limite de contas atingido!\n"
str_conta_criada:.asciiz "\nConta criada com sucesso!\n"
str_login_falha: .asciiz "Nome ou senha incorretos!\n"
str_valor_invalido: .asciiz "Valor invalido!\n"
str_saldo_insuficiente: .asciiz "Saldo insuficiente!\n"
str_destino_nao_encontrado: .asciiz "Conta de destino nao encontrada!\n"
str_auto_transferencia: .asciiz "Nao e possivel transferir para si mesmo!\n"
str_newline:     .asciiz "\n"
str_admin_senha: .asciiz "1234"  # Senha fixa para admin (4 dígitos)
valor_transferir: .word 0 
# Buffers
buffer_nome:     .space 10
buffer_senha:    .space 5    # 4  + \0
buffer: .space 100
# armazenamento das contas (3 contas)
# formato nome 10bytes, senha 5bytes, saldo 4bytes
contas_nome:     .space 30  # 3 contas * 10bytes
contas_senha:    .space 15   # 3 contas * 5bytes
contas_saldo:    .word 0, 0, 0  

# variaveis de controle
num_contas:      .word 0     #numero de contas atual
conta_atual:     .word -1    # indice da conta logada (-1 = nenhuma)
admin_logado:    .word 0     # 0 =nao, 1 =sim

.text
.globl main
main:
    # incializa variaveis
    sw $zero, num_contas     # inicializa num contas 0
    li $t0, -1               # codigo para nenhuma conta logada
    sw $t0, conta_atual      # inicializa atual com -1, nenhuma conta
    sw $zero, admin_logado   # inicializa admin logado =0 
    
    #menu principal
    menu_principal:
        #print menu
        li $v0, 4
        la $a0, str_titulo
        syscall
        
        li $v0, 4
        la $a0, str_criar_conta
        syscall
        
        li $v0, 4
        la $a0, str_login
        syscall
        
        li $v0, 4
        la $a0, str_admin
        syscall
        
        li $v0, 4
        la $a0, str_sair
        syscall
        
        li $v0, 4
        la $a0, str_opcao
        syscall
        
        #ler opcao usuario
        li $v0, 5
        syscall
        move $t0, $v0
        
        #vef opcao
        beq $t0, 1, opcao_criar_conta
        beq $t0, 2, opcao_login
        beq $t0, 3, opcao_admin
        beq $t0, 4, opcao_sair
        j menu_principal  #se invalida voltar p menu
        
    opcao_criar_conta:
        #vef limite de contas
        lw $t0, num_contas     
        li $t1, 3              #limite maximo de contas
        beq $t0, $t1, limite_contas
        nome:
        #pede o nome
        li $v0, 4
        la $a0, str_nome
        syscall
        
        #ler nome
        li $v0, 8
        la $a0, buffer_nome
        li $a1, 10
        syscall
        
        # remover \n
        la $t0, buffer_nome    #endereço do buffer_nome
        remover_newline_nome:
            lb $t1, 0($t0)     #caractere atual
            beqz $t1, fim_remover_nome
            beq $t1, 10, substituir_newline_nome  # 10 código para \n
            addi $t0, $t0, 1   #prox caractere
            j remover_newline_nome
        substituir_newline_nome:
            sb $zero, 0($t0)   #substitui \n por \0 no fim da string
        fim_remover_nome:
        
        lb $t1, buffer_nome
        bnez $t1, nome_valido
        j nome
        
        nome_valido:
        senha:
        #pede a senha
        li $v0, 4
        la $a0, str_senha
        syscall
        
        #ler senha
        li $v0, 8
        la $a0, buffer_senha
        li $a1, 5
        syscall
        
        # remove \n 
        la $t0, buffer_senha    #endereco do buffer_senha
        remover_newline_senha:
            lb $t1, 0($t0)     #caractere atual
            beqz $t1, fim_remover_senha
            beq $t1, 10, substituir_newline_senha  # 10 código para \n
            addi $t0, $t0, 1   #proximo caractere
            j remover_newline_senha
        substituir_newline_senha:
            sb $zero, 0($t0)   #substitui \n por \0, no fim da string
        fim_remover_senha:
        
        lb $t1, buffer_senha
        bnez $t1, senha_valida
        j senha
        
        senha_valida:
        
        #calc posicao na memoria para guardar o nome
        lw $t0, num_contas     #indice da nova conta
        mul $t1, $t0, 10       #offset em bytes para nome 
        la $t2, contas_nome    #endereço base do vetor de nomes
        add $t2, $t2, $t1      #endereco onde o novo nome vai ser armazenado
        
        #salva nome
        la $t3, buffer_nome    #endereco do nome digitado
        salvar_nome_no_endereco:
            lb $t4, 0($t3)     #caractere atual do nome digitado
            sb $t4, 0($t2)     #copia caractere para o destino
            beqz $t4, fim_salvar_nome_no_endereco  #se encontrou fim da string, \0
            addi $t3, $t3, 1   #proximo caractere
            addi $t2, $t2, 1   #proximo caractere
            j salvar_nome_no_endereco
        fim_salvar_nome_no_endereco:
        
        #calc posicao na memoria para guardar a senha
        lw $t0, num_contas     #indice da nova conta
        mul $t1, $t0, 5        #offset em bytes para a senha 
        la $t2, contas_senha   #endereco base do vetor de senhas
        add $t2, $t2, $t1      #endereco onde a nova senha vai ser armazenada
        
        #copia senha
        la $t3, buffer_senha   #endereco da senha digitada 
        copiar_senha:
            lb $t4, 0($t3)     #caractere atual do buffer
            sb $t4, 0($t2)     # Copia caractere para o destino
            beqz $t4, fim_copiar_senha  #se encontrou fim da string, \0
            addi $t3, $t3, 1   #proximo caractere
            addi $t2, $t2, 1   #proximo caractere
            j copiar_senha
        fim_copiar_senha:
        sb $zero, 0($t2)       #garante que a senha termine com \0
        
        # incrementa num_contas
        lw $t0, num_contas     #numero atual de contas
        addi $t0, $t0, 1       #numero atualizado de contas
        sw $t0, num_contas     # salva na memoria
        
        #print sucesso
        li $v0, 4
        la $a0, str_conta_criada
        syscall
        
        # volta ao menu
        j menu_principal
        
    limite_contas:
        # print limite atingido
        li $v0, 4
        la $a0, str_limite
        syscall
        
        j menu_principal
        
    opcao_login:
        #pede nome
        li $v0, 4
        la $a0, str_nome
        syscall
        
        # le nome
        li $v0, 8
        la $a0, buffer_nome
        li $a1, 10
        syscall
        
        # remove \n do nome
        la $t0, buffer_nome    #endereco do buffer_nome
        remover_newline_login_nome:
            lb $t1, 0($t0)     #caractere atual
            beqz $t1, fim_remover_login_nome
            beq $t1, 10, substituir_newline_login_nome  
            addi $t0, $t0, 1   #proximo caractere
            j remover_newline_login_nome
        substituir_newline_login_nome:
            sb $zero, 0($t0)   # substitui \n por \0
        fim_remover_login_nome:
        
        # pede senha
        li $v0, 4
        la $a0, str_senha
        syscall
        
        #le senha
        li $v0, 8
        la $a0, buffer_senha
        li $a1, 5
        syscall
        
        # procura conta com este nome
        li $t0, 0              #indice da conta atual (0)
        lw $t1, num_contas     #nmero total
        
        verificar_contas:
            beq $t0, $t1, login_falha  # se verificou e nao encontrou
            
            #calc posicao nome na memoria
            mul $t2, $t0, 10      #offset em bytes para o nome 
            la $t3, contas_nome   #endereco base do vetor de nomes
            add $t3, $t3, $t2     #endereco do nome da conta atual
            move $t8, $t3
            #compara
            la $t4, buffer_nome   #endereco do nome digitado
            
            comparar_nome:
                lb $t5, 0($t3)    #caractere do nome armazenado
                lb $t6, 0($t4)    #caractere do nome digitado
                
                #se chegou ao fim de ambas, sao iguais
                beqz $t5, verificar_fim_nome
                beqz $t6, nome_diferente
                
                #se tem caracteres diferentes, sao diferentes
                bne $t5, $t6, nome_diferente
                
                #proximo caractere
                addi $t3, $t3, 1  #proximo caractere doarmazenado
                addi $t4, $t4, 1  #proximo caractere do digitado
                j comparar_nome
                
            verificar_fim_nome:
                # vef se nome digitado terminou
                bnez $t6, nome_diferente
                
                # se esta aqui, sao iguais
                # vef senha
                
                # calc posicao da senha na memoria 
                mul $t2, $t0, 5       #offset em bytes para a senha 
                la $t3, contas_senha  #endereco base do vetor de senhas
                add $t3, $t3, $t2     #endereço da senha da conta atual
                
                #compara senha
                la $t4, buffer_senha  #endereço da senha digitada
                
                comparar_senha:
                    lb $t5, 0($t3)    #caractere da senha armazenada
                    lb $t6, 0($t4)    #caractere da senha digitada
                                   
                    # se chegou ao fim, sao iguais
                    beqz $t5, verificar_fim_senha
                    beqz $t6, senha_diferente
                    
                    #se caracteres diferentes,sao dif
                    bne $t5, $t6, senha_diferente
                    
                    # proximo caractere
                    addi $t3, $t3, 1  # proximo caractere da senha armazenada
                    addi $t4, $t4, 1  # proximo caractere da senha digitada
                    j comparar_senha
                
                verificar_fim_senha:
                    # vef se senha armazenada terminou
                    bnez $t5, senha_diferente
                    j login_sucesso
                    
                senha_diferente:
                    #proxima conta
                    addi $t0, $t0, 1  # incremente indice da conta
                    j verificar_contas
            
            nome_diferente:
                # oProxima conta
                addi $t0, $t0, 1  # incremente indice da conta
                j verificar_contas
        
        login_sucesso:
            # define conta como atual
            sw $t0, conta_atual  #índice da conta que fez login
            
            # vai para menu usuario
            j menu_usuario
            
        login_falha:
            # print falha
            li $v0, 4
            la $a0, str_login_falha
            syscall
            
            #print menu principal
            j menu_principal
            
    opcao_admin:
        # pede senha admin
        li $v0, 4
        la $a0, str_senha
        syscall
        
        #le senha
        li $v0, 8
        la $a0, buffer_senha
        li $a1, 5
        syscall
        
        # remover \n
        la $t0, buffer_senha    #endereço do buffer_senha
        remover_newline_admin:
            lb $t1, 0($t0)      #caractere atual
            beqz $t1, fim_remover_admin
            beq $t1, 10, substituir_newline_admin  #código  \n
            addi $t0, $t0, 1    #proximo caractere
            j remover_newline_admin
        substituir_newline_admin:
            sb $zero, 0($t0)    # substitui \n por \0
        fim_remover_admin:
        
        # compara senha 
        la $t0, buffer_senha    # endereço da senha digitada
        la $t1, str_admin_senha # endereço da senha do admin
        
        comparar_senha_admin:
            lb $t2, 0($t0)      # caractere da senha digitada
            lb $t3, 0($t1)      # caractere da senha do admin
            
            # se terminaram, sao iguais
            beqz $t2, verificar_admin_fim
            beqz $t3, admin_senha_invalida
            
            #se diferentes, sao diferentes
            bne $t2, $t3, admin_senha_invalida
            
            #proximo caractere
            addi $t0, $t0, 1
            addi $t1, $t1, 1
            j comparar_senha_admin
            
        verificar_admin_fim:
            # vef se admin tb terminou
            bnez $t3, admin_senha_invalida
            
            # se esta aqui sao iguais
            j admin_senha_valida
        
        admin_senha_invalida:
            # print falha
            li $v0, 4
            la $a0, str_login_falha
            syscall
            
            # volta menu
            j menu_principal
            
        admin_senha_valida:
            # marca admin logado
            li $t0, 1
            sw $t0, admin_logado
            
            # print menu admin
            menu_admin:
                # print menu
                li $v0, 4
                la $a0, str_menu_admin
                syscall
                
                li $v0, 4
                la $a0, str_listar_contas
                syscall
                
                li $v0, 4
                la $a0, str_logout_admin
                syscall
                
                li $v0, 4
                la $a0, str_opcao
                syscall
                
                # le opcao
                li $v0, 5
                syscall
                move $t0, $v0          # $opcao escolhida
                
                #opcao escolhida
                beq $t0, 1, admin_listar_contas
                beq $t0, 2, admin_logout
                
                # se invalida volta menu
                j menu_admin
                
            admin_listar_contas:
                # vef se existem contas
                lw $t0, num_contas     # numero de contas cadastradas
                beqz $t0, nenhuma_conta
                
                # percorre todas contas
                li $t1, 0              #ndice da conta atual
                
                listar_loop:
                    beq $t1, $t0, fim_listar_contas
                    
                    # print conta
                    li $v0, 4
                    la $a0, str_conta_info
                    syscall
                    
                    li $v0, 1
                    addi $a0, $t1, 1   # Conta #1, Conta #2, ....(índice + 1)
                    syscall
                    
                    li $v0, 4
                    la $a0, str_separador
                    syscall
                    
                    # calc posicao na memoria 
                    mul $t2, $t1, 10   # offset em bytes para o nome
                    la $t3, contas_nome #endereço base do vetor de nomes
                    add $t3, $t3, $t2  #endereço do nome da conta atual
                    
                    # print nome
                    li $v0, 4
                    move $a0, $t3
                    syscall
                    
                    # print Saldo:
                    li $v0, 4
                    la $a0, str_saldo_info
                    syscall
                    
                    # calc posicao saldo na memoria
                    mul $t2, $t1, 4    #offset em bytes para o saldo
                    la $t3, contas_saldo # endereco base do vetor de saldos
                    add $t3, $t3, $t2  # endereco do saldo da conta atual
                    lw $t4, 0($t3)     # saldo da conta atual
                    
                    # Print saldo
                    li $v0, 1
                    move $a0, $t4
                    syscall
                    
                    # Nova linha
                    li $v0, 4
                    la $a0, str_newline
                    syscall
                    
                    # Prox conta
                    addi $t1, $t1, 1
                    j listar_loop
                
                nenhuma_conta:
                    # print nenhuma conta
                    li $v0, 4
                    la $a0, str_newline
                    syscall
                    
                    li $v0, 4
                    la $a0, str_falha  #print falha
                    syscall
                
                fim_listar_contas:
                    # volta menu admin
                    j menu_admin
                
            admin_logout:
                # marca admin 0
                sw $zero, admin_logado
                
                # volta menu
                j menu_principal
        
    opcao_sair:
        # fecha programa
        li $v0, 10
        syscall
        
    # Prints Menu Usuario
    menu_usuario:
        # mostrar menu
        li $v0, 4
        la $a0, str_menu_usuario
        syscall
        
        li $v0, 4
        la $a0, str_ver_saldo
        syscall
        
        li $v0, 4
        la $a0, str_deposito
        syscall
        
        li $v0, 4
        la $a0, str_saque
        syscall
        
        li $v0, 4
        la $a0, str_transferencia
        syscall
        
        li $v0, 4
        la $a0, str_logout
        syscall
        
        li $v0, 4
        la $a0, str_opcao
        syscall
        
        # le opcao
        li $v0, 5
        syscall
        move $t0, $v0          
        
        # vef opcao 
        beq $t0, 1, opcao_ver_saldo
        beq $t0, 2, opcao_deposito
        beq $t0, 3, opcao_saque
        beq $t0, 4, opcao_transferencia
        beq $t0, 5, logout_usuario
        
        # se opcao invalida volta menu
        j menu_usuario
        
    
    opcao_ver_saldo:
        # calc posicao do saldo na memoria
        lw $t0, conta_atual    # indice da conta logada
        mul $t1, $t0, 4        # offset em bytes para o saldo 
        la $t2, contas_saldo   # endereco base do vetor de saldos
        add $t2, $t2, $t1      # endereco do saldo da conta atual
        lw $t3, 0($t2)         # valor do saldo
        
        # print saldo
        li $v0, 4
        la $a0, str_saldo
        syscall
        
        # print saldo
        li $v0, 1
        move $a0, $t3
        syscall
        
        # Nova linha
        li $v0, 4
        la $a0, str_newline
        syscall
        
        # volta menu usuario
        j menu_usuario
    
   
    opcao_deposito:
        # pede valor
        li $v0, 4
        la $a0, str_valor
        syscall
        
        #le valor
        li $v0, 5              
        syscall
        move $t0, $v0          
        
        # verifica positivo
        blez $t0, deposito_invalido
        
        # calc posicao na memoria 
        lw $t1, conta_atual    # indice da conta logada
        mul $t2, $t1, 4        # offset em bytes para o saldo 
        la $t3, contas_saldo   # endereco base do vetor de saldos
        add $t3, $t3, $t2      # endereço do saldo da conta atual
        
        # pega saldo atual e add deposito
        lw $t4, 0($t3)         # saldo atual
        add $t4, $t4, $t0      # novo saldo (atual + depósito)
        sw $t4, 0($t3)         # salva novo saldo 
        
        # print sucesso
        li $v0, 4
        la $a0, str_sucesso
        syscall
        
        # volta menu
        j menu_usuario
        
    deposito_invalido:
        # print falha
        li $v0, 4
        la $a0, str_valor_invalido
        syscall
        
        # volta menu
        j menu_usuario
    
 
    opcao_saque:
        # pede valor
        li $v0, 4
        la $a0, str_valor
        syscall
        
        # le valor
        li $v0, 5              
        syscall
        move $t0, $v0          
        
        # vef se positivo
        blez $t0, saque_invalido
        
        # calc posicao do saldo na memoria
        lw $t1, conta_atual    # indice da conta logada
        mul $t2, $t1, 4        # offset em bytes para o saldo 
        la $t3, contas_saldo   # endereco base do vetor de saldos
        add $t3, $t3, $t2      # endereco do saldo da conta atual
        
        # verifica se saldo eh suficiente
        lw $t4, 0($t3)         # saldo atual
        blt $t4, $t0, saldo_insuficiente
        
        # faz o saque
        sub $t4, $t4, $t0      # novo saldo (atual - saque)
        sw $t4, 0($t3)         # salva novo saldo 
        
        #print sucesso
        li $v0, 4
        la $a0, str_sucesso
        syscall
        
        # volta usuario
        j menu_usuario
        
    saque_invalido:
        # print falha
        li $v0, 4
        la $a0, str_valor_invalido
        syscall
        
        # volta menu
        j menu_usuario
        
    saldo_insuficiente:
        # print falha
        li $v0, 4
        la $a0, str_saldo_insuficiente
        syscall
        
        # volta menu
        j menu_usuario
    
   
    opcao_transferencia:
        # pede nome destino
        li $v0, 4
        la $a0, str_destino
        syscall
        
        # le nome destino
        li $v0, 8
        la $a0, buffer_nome     #buffer nome contem nome digitado
        li $a1, 50
        syscall
        
        # remover \n
        la $t0, buffer_nome     # endereco do buffer_nome
        remover_newline_destino:
            lb $t1, 0($t0)      #caractere atual
            beqz $t1, fim_remover_destino
            beq $t1, 10, substituir_newline_destino  #  código \n
            addi $t0, $t0, 1    # proximo caractere
            j remover_newline_destino
        substituir_newline_destino:
            sb $zero, 0($t0)    # troca \n por \0 no final da string
        fim_remover_destino:
        
        # procura conta de destino
        li $t0, 0               # índice da conta atual comeca em 0
        lw $t1, num_contas      # numero total de contas
        li $t7, -1              # indice da conta de destino comeca -1
        
        procurar_destino:
            beq $t0, $t1, destino_nao_encontrado  # se verificou todas contas e n encontrou
            
            # calc posicao na memoria
            mul $t2, $t0, 10      # offset em bytes para o nome 
            la $t3, contas_nome   # endereço base do vetor de nomes
            add $t3, $t3, $t2     # endereco do nome da conta atual
            move $t7, $t3
            
            # compara nome
            la $t4, buffer_nome   # endereco do nome digitado
            
            comparar_destino:
                lb $t5, 0($t3)    # caractere do nome armazenado
                lb $t6, 0($t4)    # caractere do nome digitado
                
                # se chegou ao fim, sao iguais
                beqz $t5, verificar_fim_destino
                beqz $t6, destino_diferente
                
                # se caracter diferente, sao diferentes
                bne $t5, $t6, destino_diferente
                
                #  proximo caractere
                addi $t3, $t3, 1  # proximo caractere do nome armazenado
                addi $t4, $t4, 1  # proximo caractere do nome digitado
                j comparar_destino
                
            verificar_fim_destino:
                # vef se nome digitado tb acabou
                bnez $t6, destino_diferente
                
                # se esta aqui, achamos conta destino
                move $t7, $t0     #indice da conta de destino
                j fim_procurar_destino
            
            destino_diferente:
                # prox conta
                addi $t0, $t0, 1  
                j procurar_destino
        
        fim_procurar_destino:
            # vef se encontrou conta destino
            li $t0, -1
            beq $t7, $t0, destino_nao_encontrado
            
            # vef se n esta indo para si mesmo
            lw $t0, conta_atual
            beq $t7, $t0, auto_transferencia
            
            # solicita valor
            li $v0, 4
            la $a0, str_valor
            syscall
            
            #ler valor
            li $v0, 5              
            syscall
            move $t0, $v0          #valor a transferir
            sw $t0, valor_transferir
            #vef se positivo
            blez $t0, transferencia_invalida
            
            # calc posicao do saldo na memoria
            lw $t1, conta_atual    # indice da conta logada (origem)
            mul $t2, $t1, 4        # offset em bytes para o saldo 
            la $t3, contas_saldo   # endereco base do vetor de saldos
            add $t3, $t3, $t2      # endereco do saldo da conta origem
            
            # pega saldo e verifica se eh suficiente
            lw $t4, 0($t3)         #saldo da conta origem
            blt $t4, $t0, transferencia_saldo_insuficiente
            
            #calc posicao do saldo conta destino
            mul $t2, $t7, 4        # offset em bytes para o saldo da conta destino
            la $t5, contas_saldo   # endereo base do vetor de saldos
            add $t5, $t5, $t2      # endereco do saldo da conta destino
            
            # pega saldo conta destino
            lw $t6, 0($t5)         # saldo da conta destino
            
            # faz a transf
            sub $t4, $t4, $t0      # novo saldo origem 
            add $t6, $t6, $t0      # novo saldo destino
            
            # salva novos saldos
            sw $t4, 0($t3)         
            sw $t6, 0($t5)         
            
            # sucess
            li $v0, 4
            la $a0, str_sucesso
            syscall
            
            # volta menu usuario
            j menu_usuario
        
        destino_nao_encontrado:
            # print falha
            li $v0, 4
            la $a0, str_destino_nao_encontrado
            syscall
            
            # volta menu usuario
            j menu_usuario
            
        auto_transferencia:
            # print falha
            li $v0, 4
            la $a0, str_auto_transferencia
            syscall
            
            # volta menu
            j menu_usuario
            
        transferencia_invalida:
            # print falja
            li $v0, 4
            la $a0, str_valor_invalido
            syscall
            
            # volta menu usuario
            j menu_usuario
            
        transferencia_saldo_insuficiente:
            # print falha
            li $v0, 4
            la $a0, str_saldo_insuficiente
            syscall
            
            # volta menu
            j menu_usuario
        
    logout_usuario:
        # seta conta atual -1 
        li $t0, -1             # codigo para nenhuma conta logada
        sw $t0, conta_atual    # atualiza var controle
        
        # volta menu 
        j menu_principal