echo "Creating python environment .venv >>> $(pwd)"
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

