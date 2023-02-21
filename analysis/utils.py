
import numpy as np
import pandas as pd
import boto3
import base64
from botocore.exceptions import ClientError
import json
import sys

def get_aws_secret(secret_name: str = "", region_name: str = "us-east-1") -> {}:
        """
            @brief: retrieves a secret stored in AWS Secrets Manager. Reqasset_idres AWS CLI and IAM user profile properly configured.
            @input:
                secret_name: the name of the secret
                region_name: region of use, default=us-east-1
            @output:
                secret: dictionary
        """
        client = boto3.session.Session().client(service_name='secretsmanager', region_name=region_name)
        secret = '{"None": "None"}'
        if (len(secret_name) < 1):
            print("[ERROR] no secret name provided.")
        else:
            try:
                res = client.get_secret_value(SecretId=secret_name)
                if 'SecretString' in res:
                    secret = res['SecretString']
                elif 'SecretBinary' in res:
                    secret = base64.b64decode(res['SecretBinary'])
                else:
                    print("[ERROR] secret keys not found in response.")
            except ClientError as e:
                print(e)

        return json.loads(secret)
    
    
def load_json(log_location, data_header, footer):
    fname = log_location + '/' + data_header + footer
    with open(fname, 'r') as f:
        data = json.loads(f.read())
    return data


def parse_json(json_object, target_key, res=[]):
    if type(json_object) is dict and json_object:
        for key in json_object:
            if key == target_key:
                res.append(json_object[key])
            parse_json(json_object[key], target_key, res)

    elif type(json_object) is list and json_object:
        for item in json_object:
            parse_json(item, target_key, res)
    
    return res


def chunk_generator(X, n):
    """
        @brief: breaks large data into smaller equal pieces + remainder as last yield
        
        @params:
            X: <dataframe> the dataframe to be broken into chunks
            n: <int> the batch size
            
        @returns:
            generator object
    """
    for i in range(0, len(X), n):
        yield i+1, X[i:i+n]
        

def chunk_dataframe(df, chunk_size = 3000000): 
    """
    splits a dataframe into chunks by chunk size (i.e. row count)
    """
    chunks = list()
    num_chunks = len(df) // chunk_size + 1
    for i in range(num_chunks):
        chunks.append(df[i*chunk_size:(i+1)*chunk_size].copy())
    return chunks


def progressbar(iterator, prefix="", size=60, out=sys.stdout): # Python3.3+
    count = len(iterator)
    def show(j):
        x = int(size*j/count)
        print("{}[{}{}] {}/{}".format(prefix, u"#"*x, "."*(size-x), j, count), 
                end='\r', file=out, flush=True)
    show(0)
    for i, item in enumerate(iterator):
        yield item
        show(i+1)
    print("\n", flush=True, file=out)
    
    
