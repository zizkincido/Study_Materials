from library import (
    BOOKS, _next_book_id, add_book, search_books,
    borrow_book, return_book, list_overdue, save_to_file, load_from_file
)
import os
from datetime import datetime, timedelta

def run_tests():
    # ID üretimi
    books_tmp = []
    assert _next_book_id.__doc__ is not None  # sadece varlık testi
    # Öğrenci implementasyonuna göre: boşsa 1
    try:
        nid = _next_book_id(books_tmp)
    except NotImplementedError:
        print("Önce _next_book_id fonksiyonunu tamamlayın.")
        return
    assert nid == 1, "Boş listede ilk id 1 olmalı"

    # add_book
    bcount = len(BOOKS)
    new = add_book(BOOKS, "Sefiller", "Victor Hugo")
    assert new["id"] > 0 and new["available"] is True
    assert len(BOOKS) == bcount + 1

    # search_books (case-insensitive ve boş query)
    assert search_books(BOOKS, "dUnE")[0]["title"] == "Dune"
    assert search_books(BOOKS, "") == []

    # borrow/return
    added_id = new["id"]
    assert borrow_book(BOOKS, added_id, "mehmet", days=1) is True
    assert borrow_book(BOOKS, added_id, "ali") is False  # zaten meşgul
    assert return_book(BOOKS, added_id) is True
    assert return_book(BOOKS, 99999) is False

    # list_overdue
    # 3 numaralı kitap zaten gecikmiş örnek
    today = (datetime.now()).strftime("%Y-%m-%d")
    overs = list_overdue(BOOKS, today=today)
    assert any(b["id"] == 3 for b in overs), "ID 3 gecikmiş olmalı"

    # save/load
    path = "books_test.json"
    save_to_file(BOOKS, path)
    loaded = load_from_file(path)
    assert isinstance(loaded, list) and len(loaded) >= len(BOOKS) - 0
    os.remove(path)

    print("Tüm testler geçti! 🚀")

if __name__ == "__main__":
    run_tests()
