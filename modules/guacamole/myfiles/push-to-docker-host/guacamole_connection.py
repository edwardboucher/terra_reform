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
    salt = os.urandom(32)
    salt_hex = salt.hex().upper()
    combined = password.encode() + salt_hex.encode()
    password_hash = hashlib.sha256(combined).hexdigest()
    return salt_hex, password_hash

def create_guacamole_connection_sql(connection_name: str, host: str, username: str, password: str) -> str:
    """
    Generate SQL to create a new Guacamole connection.

    Args:
        connection_name (str): Name of the connection.
        host (str): IP address or FQDN of the remote host.
        username (str): Username for the connection.
        password (str): Password for the connection.

    Returns:
        str: SQL statements to insert the connection into the Guacamole database.
    """
    # Generate a unique connection ID and hash the password
    connection_id = os.urandom(4).hex().upper()  # Random 4-byte hex ID
    salt_hex, hashed_password = generate_guacamole_password_hash(password)

    # SQL for guacamole_connection
    connection_sql = f"""
INSERT INTO guacamole_connection (connection_id, connection_name, protocol)
VALUES ({int(connection_id, 16)}, '{connection_name}', 'rdp');
"""

    # SQL for guacamole_connection_parameter
    parameters_sql = f"""
INSERT INTO guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
VALUES
    ({int(connection_id, 16)}, 'hostname', '{host}'),
    ({int(connection_id, 16)}, 'username', '{username}'),
    ({int(connection_id, 16)}, 'password', '{password}');
"""

    # Combine both SQL statements
    return connection_sql + parameters_sql

# Example usage
if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 script.py <connection_name> <host> <username> <password>")
        sys.exit(1)

    connection_name = sys.argv[1]
    host = sys.argv[2]
    username = sys.argv[3]
    password = sys.argv[4]

    sql_statements = create_guacamole_connection_sql(connection_name, host, username, password)
    print(sql_statements)
#example: python3 guacamole_connection.py "MyConnection" "192.168.1.100" "user" "password123"
