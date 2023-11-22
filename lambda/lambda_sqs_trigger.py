
def lambda_handler(event, context):
    print(event, context)

    return {
        'Success': 'Yes'
    }