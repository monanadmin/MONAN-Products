module load python-3.9.13-gcc-9.4.0-moxjnc6 

echo "Creating python environment .venv >>> $(pwd)"
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

