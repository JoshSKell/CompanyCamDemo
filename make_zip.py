import zipfile

with zipfile.ZipFile('deployment_package.zip', 'w') as zf:
    zf.write('app.py')
