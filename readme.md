# DebugAI – Diagnóstico de Erros DevOps com IA

## Descrição do Projeto
Agente inteligente para diagnóstico de erros DevOps, containerizado e provisionado via IaC (Terraform), com pipeline CI/CD automatizado e testes.

## Como o agente funciona
- Interface web via Streamlit
- Recebe logs/erros do usuário
- Usa Gemini API para gerar respostas técnicas
- Histórico de conversa e sugestões práticas

## Infraestrutura provisionada (IaC)
- **Terraform**: Provisiona EC2 na AWS, rede personalizada, Security Group
- **Docker**: Containeriza o agente para fácil deploy
- **GitHub Actions**: Pipeline CI/CD para build, testes e simulação de deploy
- **Codespaces**: Ambiente remoto para desenvolvimento e testes

## Como executar o projeto
1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/seu-repo.git
   cd IA-Generativa-DebugAI
   ```
2. **Crie o arquivo `.env`**
   ```
   GEMINI_API_KEY=sua_chave_aqui
   ```
3. **Crie e ative o ambiente virtual**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
4. **Rode localmente**
   ```bash
   streamlit run main.py
   ```
5. **Rode os testes**
   ```bash
   pytest
   ```
6. **Build Docker**
   ```bash
   docker build -t debugai .
   docker run -p 8501:8501 --env-file .env debugai
   ```

## Como provisionar infraestrutura (Terraform)
1. Configure suas credenciais AWS
2. Edite `terraform/main.tf` se necessário
3. Execute:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

## Pipeline CI/CD (GitHub Actions)
- Instala dependências
- Executa testes automatizados
- Build Docker
- Simula deploy (Terraform plan)
- Exemplo: `.github/workflows/ci-cd.yml`

## Testes automatizados
- Testes em `test_main.py` (raiz ou pasta `tests/`)
- Use pytest para rodar todos os testes
- Exemplo de teste:
  ```python
  def test_erro_simulado():
      assert 1 == 2  # Teste propositalmente falho
  ```

## Como usar no GitHub Codespaces
- Clique em "Code" > "Codespaces" > "Create codespace"
- Ambiente já configurado para rodar Streamlit, Docker, Terraform e testes
- Edite, teste e execute tudo remotamente

## Estrutura de diretórios
```
IA-Generativa-DebugAI/
├── .env
├── main.py
├── requirements.txt
├── readme.md
├── Dockerfile
├── terraform/
│   └── main.tf
├── tests/
│   └── test_main.py
└── .github/
    └── workflows/
        └── ci-cd.yml
```

## Comentários e dicas
- Todos os scripts e arquivos estão comentados para facilitar entendimento
- O pipeline CI/CD pode ser expandido para deploy real
- O Makefile pode ser adicionado para automatizar comandos locais
- O projeto está pronto para ser apresentado e evoluído


Apaga tudo do terraform pra usar em uma nova conta lab.
rm -rf terraform/.terraform terraform/.terraform.lock.hcl terraform/terraform.tfstate terraform/terraform.tfstate.backup
