from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='analisi.ad.mediamond.it',port='5000')


def main():
    return render_template('index.html')


@app.route('/showSignUp')
def showSignUp():
    return render_template('login.html')

