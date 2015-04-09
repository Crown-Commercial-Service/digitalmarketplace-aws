def set_boto_response(mock_object, method_name, response=None, metadata=None):
    getattr(mock_object, method_name).return_value = boto_response_dict(
        method_name, response, metadata
    )


def set_boto_responses(mock_object, method_name, responses):
    getattr(mock_object, method_name).side_effect = [
        boto_response_dict(method_name, response, metadata)
        for response, metadata in responses
    ]


def boto_response_dict(method_name, response=None, metadata=None):
    method_key = method_name.title().replace('_', '')
    return {
        '{}Response'.format(method_key): {
            '{}Result'.format(method_key): response,
            'ResponseMetadata': metadata,
        }
    }
