import hashlib
import os
import sys

def generate_guacamole_password_hash(password: str) -> tuple:
    """
    Generate a password hash and salt for Apache Guacamole using the provided password.

    Args:
        password (str): The plaintext password to hash.

    Returns:
        tuple: A tuple containing the salt (hexadecimal format) and the hashed password (hexadecimal format).
    """
    # Generate a 32-byte cryptographically secure random salt
    salt = os.urandom(32)

    # Convert the salt to its hexadecimal representation
    salt_hex = salt.hex().upper()

    # Concatenate the password and the upper-case hex representation of the salt
    combined = password.encode() + salt_hex.encode()

    # Compute the SHA-256 hash
    password_hash = hashlib.sha256(combined).hexdigest()

    return salt_hex, password_hash

# Example usage
if __name__ == "__main__":
    if "--sql" in sys.argv:
        if len(sys.argv) < 4:
            print("Usage: python3 guacamole_hash.py <password> --sql <username>")
            sys.exit(1)
        password = sys.argv[1]
        username = sys.argv[3]
    else:
        password = sys.argv[1] if len(sys.argv) > 1 else input("Enter password: ")
        username = "guacadmin"

    salt_hex, hashed_password = generate_guacamole_password_hash(password)

    if "--sql" in sys.argv:
#         sql_statement = f"""
# INSERT INTO guacamole_user (username, password_hash, password_salt, password_date)
# VALUES ('{username}',
#     x'{hashed_password}',
#     x'{salt_hex}',
#     NOW());
# """
        sql_statement = f"""
UPDATE guacamole_user 
SET password_hash = decode('{hashed_password.upper()}', 'hex'),
    password_salt = decode('{salt_hex.upper()}', 'hex'),
    password_date = NOW()
WHERE entity_id = (
    SELECT entity_id 
    FROM guacamole_entity 
    WHERE name = '{username}' AND type = 'USER'
);
"""
        print(sql_statement)
    else:
        print(f"Generated salt: {salt_hex}")
        print(f"Generated hash: {hashed_password}")

#example: python3 guacamole_hash.py guacadmin --sql