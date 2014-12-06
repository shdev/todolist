#!/usr/bin/env python3

from couchdb import Server
import sys
import logging
import argparse


#
#   Setup the parser and the loglevel
#
parser = argparse.ArgumentParser(description='A todo list with a couchdb '
                                 'backend',
                                 epilog="I wish you a peaceful time.")

parser.add_argument('--log', dest='loglevel', choices=["CRITICAL", "ERROR",
                    "WARNING", "INFO", "DEBUG"], default="ERROR",
                    help="choose your log level")

parser.add_argument('--server', dest='server', help="couchdb server",
                    required=True)

parser.add_argument('--port', dest='port', help="server port", type=int,
                    required=True)

parser.add_argument('--credentials', dest='credentials', help="credentials",
                    type=str, required=True)

parser.add_argument('--database', dest='database', help="database",
                    type=str, required=True)

parser.add_argument('--protocol', dest='protocol', help="protocol",
                    type=str, required=True)


args = parser.parse_args()

loglevel = args.loglevel

numeric_level = getattr(logging, loglevel.upper(), None)
if not isinstance(numeric_level, int):
    raise ValueError('Invalid log level: %s' % loglevel)

logging.basicConfig(filename='logs/couchtodo.log', level=numeric_level,
                    format='%(asctime)s [%(levelname)s]: %(message)s')

#
#   setup is done
#


class SHTodolist:
    """docstring for SHTodolist"""

    __configuration = {}

    __server_instance = None
    __db = None

    def validate_configuration(configuration):
        pass

    def __init__(self,
                 server_name="localhost",
                 port="",
                 credentials="",
                 protocol="http",
                 database="",
                 list_view="todolist/lists",
                 entry_view="todolist/entries"):
        self.__configuration['server_name'] = server_name.strip()
        self.__configuration['credentials'] = credentials
        self.__configuration['protocol'] = protocol

        if None == port or "" == port.strip():
            if "https" == protocol:
                port = "6984"
            else:
                port = "5984"

        self.__configuration['port'] = port
        self.__configuration['database'] = database
        self.__configuration['list_view'] = list_view
        self.__configuration['entry_view'] = entry_view

    def server_url(self):
        return self.__configuration['protocol'] + "://" + \
            self.__configuration['credentials'] + "@" + \
            self.__configuration['server_name'] + ":" + \
            self.__configuration['port']

    def initDB(self):
        if None == self.__server_instance:
            self.__server_instance = Server(self.server_url())
        if None == self.__db:
            self.__db = self.__server_instance[
                self.__configuration['database']
            ]

    def print_lists(self):
        self.initDB()
        lists = {}

        for row in self.__db.view(self.__configuration["list_view"]):
            stripped_list_name = str(row.value).strip()
            if hasattr(lists, stripped_list_name):
                lists[stripped_list_name].append(row.id)
            else:
                lists[stripped_list_name] = [row.id]

        for list_name in sorted(lists, key=str.lower):
            print(list_name)

if __name__ == '__main__':
    try:
        logging.info('Oh yeah it starts')
        todolist = SHTodolist(args.server, str(args.port), args.credentials,
                              args.protocol, args.database)
        todolist.print_lists()

    except Exception as e:
        sys.stderr.write("Something went here extremly wrong, and I don't "
                         "know why\n")
        logging.critical("Something went here extremly wrong, and I don't "
                         "know why")
    finally:
        pass
