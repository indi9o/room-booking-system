#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    """Run administrative tasks."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "room_usage_project.settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? "
            "This application is designed to run via Docker containers. "
            "Please use: ./tools/docker_django.sh [command]"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
