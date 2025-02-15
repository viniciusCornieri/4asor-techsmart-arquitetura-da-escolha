workspace "TechSmart" "E-commerce integrado com DREX"

    !identifiers hierarchical

    model {
        cliente = person "Cliente" "Cliente que faz compras na TechSmart"

        techSmart = softwareSystem "TechSmart" "E-commerce integrado com DREX" {

            apiGateway = container "API Gateway" "Controla entrada das requisições externas"

            group "frontend" {
                web = container "Web frontend" {
                    tags "Web"
                }

                bff = container "BFF" {
                    tags "Microservice"
                }
            }

            apiManagement = container "API Management" "Gerenciador de Apis" {

            }

            group "services" {
                cadastroCliente = container "API Cadastro de Clientes" {
                    tags "Microservice"
                }

                cadastroProdutos = container "API Cadastro de Produtos" {
                    tags "Microservice"
                }

                configuracoes = container "API Configuracoes" {
                    tags "Microservice"
                }

                carrinhoDeCompras = container "API Carrinho de compras" {
                    tags "Microservice"
                }

                comprasRealizadas = container "API Compras realizadas" {
                    tags "Microservice"
                }

                pagamentos = container "API de Pagamentos" {
                    tags "Microservice"

                    paymentController = component "Payment Controller" "Controlador REST para operações de pagamento" {
                        tags "Controller"
                    }
                    
                    drexProcessor = component "DREX Processor" "Processa pagamentos específicos em DREX" 
                    creditProcessor = component "Credit Processor" "Processa pagamentos específicos em cartões de Crédito" 
                    debitProcessor = component "Debit Processor" "Processa pagamentos específicos em cartões de Débito" 
                    pixProcessor = component "PIX Processor" "Processa pagamentos específicos em PIX" 
                    
                    paymentOrchestrator = component "Payment Orchestrator" "Orquestra o fluxo de pagamento" 
                    
                    drexConverter = component "DREX Converter" "Converte valores entre DREX e Real" 
                    
                    transactionManager = component "Transaction Manager" "Gerencia transações e retry" 
                    
                    paymentRepository = component "Payment Repository" "Acessa dados de pagamento" 
                    
                    drexBlockchainAdapter = component "DREX Blockchain Adapter" "Interface com blockchain DREX" {
                        tags "Adapter"
                    }

                    creditCardAdapter = component "Credit card Adapter" "Interface para cartões de crédito" {
                        tags "Adapter"
                    }


                    debitCardAdapter = component "Debit card Adapter" "Interface para cartões de débito" {
                        tags "Adapter"
                    }

                    pixAdapter = component "Pix Adapter" "Interface para Pix" {
                        tags "Adapter"
                    }
                    
                    
                    # Relacionamentos internos
                    paymentController -> paymentOrchestrator "Inicia processamento"
                    transactionManager -> paymentRepository "Persiste dados"
                    paymentOrchestrator -> drexProcessor "Processa DREX"
                    paymentOrchestrator -> drexConverter "Converte valores"
                    paymentOrchestrator -> transactionManager "Gerencia transação"
                    paymentOrchestrator -> creditProcessor "Processa pagamentos em cartão de crédito"
                    paymentOrchestrator -> debitProcessor "Processa pagamentos em cartão de débito"
                    paymentOrchestrator -> pixProcessor "Processa pagamentos em PIX"
                    drexProcessor -> drexBlockchainAdapter "Interage com interface DREX"
                    creditProcessor -> creditCardAdapter "Interage com interface de cartão de crédito"
                    debitProcessor -> debitCardAdapter "Interage com de cartão de débito"
                    pixProcessor -> pixAdapter "Interage com iterface de PIX"
                    
                }
            }

            group "Containers de dados" {
                noSql = container "NoSQL database cadastros" {
                    tags "Database"
                }

                relational = container "DB Relacional Movimentação de Compras" {
                    tags "Database"
                }

                cache = container "NoSQL Cache Carrinho de Compras" {
                    tags "Database"
                }
            }
        }

        tef = softwareSystem "Ambiente TEF" "Fornecedores de interface de comunicação para transações financeiras" {
            tags "External"
        }

        bancoCentral = softwareSystem "Banco Central" {
            tags "External"
        }

        instituicoesFinanceira = softwareSystem "Instituições financeiras" {
            tags "External"
        }

        #Relacionamentos externos

        cliente -> techSmart.apiGateway "Faz compras usando DREX"
        techSmart.pagamentos -> tef "Solicita transações financeiras" "REST"
        tef -> bancoCentral "Faz transações financeiras"
        tef -> instituicoesFinanceira "Faz transações financeiras"

        techSmart.apiGateway -> techSmart.web "Redireciona fluxo"
        techSmart.apiGateway -> techSmart.bff "Redireciona fluxo"

        techSmart.web -> techSmart.apiManagement "Faz requisições"
        techSmart.bff -> techSmart.apiManagement "Faz requisições"

        techSmart.apiManagement -> techSmart.cadastroCliente "Balanceia e gerencia APIS"
        techSmart.apiManagement -> techSmart.cadastroProdutos "Balanceia e gerencia APIS"
        techSmart.apiManagement -> techSmart.configuracoes "Balanceia e gerencia APIS"
        techSmart.apiManagement -> techSmart.carrinhoDeCompras "Balanceia e gerencia APIS"
        techSmart.apiManagement -> techSmart.comprasRealizadas "Balanceia e gerencia APIS"
        techSmart.apiManagement -> techSmart.pagamentos.paymentController "Balanceia e gerencia APIS" "REST"

        techSmart.cadastroCliente -> techSmart.noSql "Persiste dados"
        techSmart.cadastroProdutos -> techSmart.noSql "Persiste dados"
        techSmart.configuracoes -> techSmart.noSql "Persiste dados"
        techSmart.carrinhoDeCompras -> techSmart.cache "Persiste dados"
        techSmart.comprasRealizadas -> techSmart.relational "Persiste dados"
        techSmart.pagamentos.paymentRepository -> techSmart.relational "Persiste dados"
        techSmart.pagamentos.paymentRepository -> techSmart.cache "Persiste/Consulta dados"

        techSmart.pagamentos.creditCardAdapter -> tef "Interface com sistema TeF" "HTTPS/REST"
        techSmart.pagamentos.debitCardAdapter -> tef "Interface com sistema TeF" "HTTPS/REST"
        techSmart.pagamentos.pixAdapter -> tef "Interface com sistema TeF" "HTTPS/REST"
        techSmart.pagamentos.drexBlockchainAdapter -> tef "Interface com sistema TeF" "HTTPS/REST"

    }

    views {
        systemContext techSmart "DiagramaC1-Contexto" {
            include * bancoCentral instituicoesFinanceira
            autolayout lr
        }

        container techSmart "DiagramaC2-Container" {
            include * bancoCentral instituicoesFinanceira
            # autolayout lr
        }

        component techSmart.pagamentos "DiagramaC3-Componente-pagamentos" {
            include *
            autolayout lr
        }

        theme default

        styles {
            element "External" {
                background #808080
            }

            element "Database" {
                shape cylinder
            }

            element "Queue" {
                shape pipe
            }

            element "Microservice" {
                shape Hexagon
            }

            element "Web" {
                shape WebBrowser
            }

            element "Controller" {
                shape hexagon
            }
            
            element "Repository" {
                shape cylinder
                background #7D69CB
            }
            
            element "Adapter" {
                shape Hexagon
                background #D64292
            }

        }
    }

}