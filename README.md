# DebugAI – Diagnóstico de Erros DevOps com IA

## 📌 Descrição do Projeto
O **DebugAI** é um agente inteligente para diagnóstico de erros DevOps, containerizado com **Docker**, provisionado com **Terraform** na AWS, e integrado a um pipeline de **CI/CD com GitHub Actions**.

Ele fornece uma interface web via **Streamlit** que recebe logs/erros do usuário e utiliza a **Gemini API** para gerar respostas técnicas com histórico de conversas e sugestões práticas.

---

## 🚀 Como o agente funciona
- **Frontend**: Interface web com **Streamlit**  
- **Diagnóstico**: Recebe logs/erros e consulta a **Gemini API**  
- **Respostas inteligentes**: Sugestões práticas para troubleshooting  
- **Histórico de conversa**: Contexto contínuo para o usuário  

---

## ☁️ Infraestrutura (IaC)
- **Terraform**
  - Cria rede personalizada (**VPC, Subnet, Internet Gateway, Route Table**)  
  - Configura **Security Group** liberando porta `8501` (Streamlit)  
  - Cria/Importa par de chaves **SSH** para acesso à EC2  
  - Provisiona instância **EC2 Ubuntu 22.04** que instala Docker, clona o repositório e sobe o container automaticamente  

- **Docker**
  - Containeriza a aplicação **Streamlit**  
  - Permite rodar com `.env` para passar segredos  

- **GitHub Actions**
  - Pipeline CI/CD com jobs de:
    - Instalação de dependências Python
    - Execução de testes automatizados (**pytest**)
    - Build da imagem Docker
    - Execução de `terraform init/validate/plan`
    - Workflow adicional para `terraform destroy` (limpeza de labs CloudGuru)

---

## 🖥️ Como executar localmente

Clone o repositório:
```bash
git clone https://github.com/seu-usuario/IA-Generativa-DebugAI.git
cd IA-Generativa-DebugAI
```

Crie o arquivo `.env`:
```env
GEMINI_API_KEY=sua_chave_aqui
```

Crie e ative o ambiente virtual:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Rode localmente:
```bash
streamlit run main.py
```

---

## 🧪 Testes
Rodar todos os testes com **pytest**:
```bash
pytest
```

Exemplo de teste:
```python
def test_erro_simulado():
    assert 1 == 2  # Teste propositalmente falho
```

---

## 🐳 Build Docker
```bash
docker build -t debugai .
docker run -p 8501:8501 --env-file .env debugai
```

---

## ⚙️ Provisionar Infraestrutura (Terraform)

Configure suas credenciais AWS (**secrets ou CLI**).

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Para limpar o ambiente (importante em labs como CloudGuru):
```bash
terraform destroy -auto-approve
```

Ou manualmente, caso queira resetar tudo:
```bash
rm -rf terraform/.terraform terraform/.terraform.lock.hcl terraform/terraform.tfstate terraform/terraform.tfstate.backup
```

---

## 🔄 CI/CD – GitHub Actions
Workflow principal (`.github/workflows/ci-cd.yml`):
- Instala dependências Python
- Executa testes automatizados
- Build Docker
- `terraform plan` (simulação de deploy)
- Pipeline auxiliar: `terraform destroy` antes de `apply` em labs

## 📂 Estrutura do Projeto
```
IA-Generativa-DebugAI/
├── .env
├── main.py
├── requirements.txt
├── Dockerfile
├── Docker-compose.yml
├── test_main.py
├── terraform/
│   ├── main.tf
│   └── modules/
│       ├── ec2/
│       │   ├── variables.tf
|       |   ├── outputs.tf
│       │   └── main.tf
│       └── security_group/
│           ├── variables.tf
|           ├── outputs.tf
│           └── main.tf
│   
└── .github/
    └── workflows/
        └── ci-cd.yml
```

---

## 📝 Observações importantes
- **Evitar subir `.env`** para o repositório (risco de segurança).  
- O **GEMINI_API_KEY** deve ser armazenado no **AWS Secrets Manager** ou **GitHub Secrets**.  
- O erro de **VPCLimitExceeded** ocorre em labs CloudGuru → usar `terraform destroy` sempre antes de `apply`.  
