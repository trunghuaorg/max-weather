import logging
import os
import time
from logging.handlers import TimedRotatingFileHandler

from app.appconfig import app

ERROR_LOG_PATH = './logs/error'
INFO_LOG_PATH = './logs/info'


def valid_log_path(path):
    if os.path.exists(path):
        pass
    else:
        os.makedirs(path)


def config(app_logger, log_level):
    valid_log_path(INFO_LOG_PATH)
    valid_log_path(ERROR_LOG_PATH)

    app_logger.setLevel(log_level)
    log_format = '%(asctime)s | %(levelname)s | %(thread)d | %(filename)s - %(funcName)s : %(message)s'
    formatter = logging.Formatter(log_format)

    info_file_name = 'info-' + time.strftime('%Y-%m-%d', time.localtime(time.time())) + '.log'
    info_handler = TimedRotatingFileHandler(filename='logs/info/' + info_file_name, when="midnight", backupCount=7,
                                            encoding='utf-8')
    info_handler.setFormatter(formatter)
    info_handler.setLevel(logging.INFO)

    error_file_name = 'error-' + time.strftime('%Y-%m-%d', time.localtime(time.time())) + '.log'
    error_handler = TimedRotatingFileHandler(filename='logs/error/' + error_file_name, when="midnight", backupCount=7,
                                             encoding='utf-8')
    error_handler.setFormatter(formatter)
    error_handler.setLevel(logging.ERROR)

    app_logger.addHandler(info_handler)
    app_logger.addHandler(error_handler)

    # logging.basicConfig()
    # logger_sql = logging.getLogger('sqlalchemy.engine')
    # logger_sql.setLevel(logging.INFO)

    return app_logger


logger = config(app.logger, 'INFO')
