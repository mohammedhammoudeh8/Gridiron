"""Fails if HTML tags are left open or closed out of order."""
import sys
from html.parser import HTMLParser

VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "source", "track", "wbr"}


class Checker(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack = []
        self.errors = []

    def handle_starttag(self, tag, attrs):
        if tag not in VOID:
            self.stack.append((tag, self.getpos()[0]))

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        if not self.stack or self.stack[-1][0] != tag:
            self.errors.append(f"line {self.getpos()[0]}: unexpected </{tag}>")
            return
        self.stack.pop()


path = sys.argv[1]
c = Checker()
c.feed(open(path, encoding="utf-8").read())
c.close()
for tag, line in c.stack:
    c.errors.append(f"line {line}: <{tag}> never closed")

if c.errors:
    print("\n".join(c.errors[:20]))
    sys.exit(1)
print("HTML structure OK")
