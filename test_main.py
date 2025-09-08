# test_main.py
from main import generate_response

def test_generate_response_mock():
    class MockModel:
        def generate_content(self, prompt):
            return type('obj', (object,), {'text': 'Resposta mock'})()
    # Simula o st.session_state
    import streamlit as st
    st.session_state.messages = [{"role": "user", "content": "erro"}]
    response = generate_response(MockModel(), "erro")
    assert response == "Resposta mock"

