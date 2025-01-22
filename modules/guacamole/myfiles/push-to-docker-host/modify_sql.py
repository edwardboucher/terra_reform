import re

def modify_sql_file(input_file, output_file, new_hash, new_salt):
    """
    Modifies an SQL file by replacing password hash and salt values.
    
    Args:
        input_file (str): Path to the input SQL file
        output_file (str): Path to save the modified SQL file
        new_hash (str): New password hash value to insert
        new_salt (str): New password salt value to insert
    """
    # Read the input file
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Replace the hash value
    content = re.sub(
        r"decode\('([A-Z]+)', 'hex'\),\s+-- 'guacadmin'",
        f"decode('{new_hash}', 'hex'),  -- 'guacadmin'",
        content
    )
    
    # Replace the salt value
    content = re.sub(
        r"decode\('([A-Z]+)', 'hex'\),",
        f"decode('{new_salt}', 'hex'),",
        content,
        count=1  # Only replace the first occurrence after the hash
    )
    
    # Write the modified content to the output file
    with open(output_file, 'w') as f:
        f.write(content)

# Example usage
if __name__ == "__main__":
    input_file = "initdb.sql"
    output_file = "modified_initdb.sql"
    new_hash = "NEW_HASH_VALUE_HERE"
    new_salt = "NEW_SALT_VALUE_HERE"
    
    modify_sql_file(input_file, output_file, new_hash, new_salt)