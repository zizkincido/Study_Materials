"""
Mini Kütüphane 2.0
- Kitap ekleme, ödünç alma, iade etme
- Arama ve gecikenleri listeleme
- Kaydet/Yükle (JSON)

Öğrenci Görevleri:
1) BUGFIX bölümlerindeki hataları düzeltin.
2) TODO bölümlerini talimatlara göre doldurun.
3) tests.py dosyasını çalıştırarak doğrulayın.
"""

from datetime import datetime, timedelta
import json
from typing import List, Dict, Optional

# ---------------------------
# Veri Modeli (basit düzey)
# ---------------------------
# Her kitap bir dict:
# {
#   "id": int,
#   "title": str,
#   "author": str,
#   "available": bool,
#   "borrower": Optional[str],
#   "due_date": Optional[str]   # ISO tarih "YYYY-MM-DD"
# }

def _today_str() -> str:
    return datetime.now().strftime("%Y-%m-%d")


def _in_days_str(days: int) -> str:
    return (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")


# ---------------------------
# ÖRNEK VERİ
# ---------------------------
BOOKS: List[Dict] = [
    {"id": 1, "title": "Dune", "author": "Frank Herbert", "available": True,  "borrower": None, "due_date": None},
    {"id": 2, "title": "Kürk Mantolu Madonna", "author": "Sabahattin Ali", "available": True,  "borrower": None, "due_date": None},
    {"id": 3, "title": "1984", "author": "George Orwell", "available": False, "borrower": "ayse", "due_date": _in_days_str(-2)},  # gecikmiş örnek
]


# -------------------------------------------------
# GÖREV 1 — BUGFIX: kitap ID üretimindeki hata
# -------------------------------------------------
# Amaç: yeni kitap eklerken benzersiz ID ver.
# HATA: Maksimum ID'yi yanlış hesaplıyor, listedeki
#       son elemana bakıyor. Liste sırası değişirse patlar.
#       Ayrıca boş liste durumunu da bozuk ele alıyor.

def _next_book_id(books: List[Dict]) -> int:
    """ Test scriptinde bulunan varlık testi için yazılmıştır."""
    # BUGGY KOD (düzeltin):
    # return books[-1]["id"] + 1

    # BEKLENEN:
    # - Liste boşsa 1 dön
    # - Aksi halde max id + 1
    if not books: # Boş liste 1 döndürür
        return 1
    return max(book["id"] for book in books) + 1 # Max fonskiyonu ile en büyük id bulur sonra 1 ekler



# -------------------------------------------------
# GÖREV 2 — Fonksiyon: kitap ekle
# -------------------------------------------------
def add_book(books: List[Dict], title: str, author: str) -> Dict:
    """
    Yeni bir kitap ekler ve eklenen kitabı döner.
    - title/author boş bırakılamaz (boşsa ValueError)
    - available True, borrower/due_date None
    """
    if not title or not author: # Yazar veya başlık kısmı boş mu?
        raise ValueError("Yazar ve başlık kısmı boş bırakılamaz.")
    new_book = { #Yeni kitabın değerleri
        "id": _next_book_id(books),
        "title": title.strip(),
        "author": author.strip(),
        "available": True,
        "borrower": None,
        "due_date": None
    }
    books.append(new_book) #Yeni kitap dict'e eklenir
    return new_book
    

# -------------------------------------------------
# GÖREV 3 — BUGFIX: arama hataları
# -------------------------------------------------
def search_books(books: List[Dict], query: str) -> List[Dict]:
    """
    Başlık ya da yazarda 'query' geçenleri (case-insensitive) döndürür.
    Boş query -> boş liste.
    """
    if not query:
        return []
    query_lower = query.lower()
    results = [b for b in books if (query_lower in b["title"].lower() or query_lower in b["author"].lower())]
    return results
    


# -------------------------------------------------
# GÖREV 4 — Fonksiyon: ödünç alma
# -------------------------------------------------
def borrow_book(books: List[Dict], book_id: int, username: str, days: int = 14) -> bool:
    """
    book_id'li kitabı 'username' adına 'days' günlüğüne ayırır.
    Dönüş: True (başarılı) / False (kitap zaten müsait değil ya da yok)
    """
    borrowed_book = next((book for book in books if book["id"] == book_id),None)
    if borrowed_book["available"]:
        borrowed_book["available"] = False
        borrowed_book["borrower"] = username
        borrowed_book["due_date"] = _in_days_str(days)
        return True
    else:
        return False


# -------------------------------------------------
# GÖREV 5 — Fonksiyon: iade etme
# -------------------------------------------------
def return_book(books: List[Dict], book_id: int) -> bool:
    """
    Kitabı iade eder; bulunursa alanları sıfırlar.
    True/False döner.
    """
    returned_book = next((book for book in books if book["id"] == book_id),None)
    if not returned_book:
        return False
    else:
        returned_book["available"] = True
        returned_book["borrower"] = None
        returned_book["due_date"] = None
        return True
    

# -------------------------------------------------
# GÖREV 6 — Gecikenleri listele
# -------------------------------------------------
def list_overdue(books: List[Dict], today: Optional[str] = None) -> List[Dict]:
    """
    'today' (YYYY-MM-DD) tarihine göre geciken kitapları döndür.
    Notlar:
      - available True olanlar gecikmiş sayılmaz
      - due_date None olanlar da değil
    """
    today = today or _today_str()
    due_list = [book for book in books if not book["available"] and book["due_date"] is not None and book["due_date"] < today]
    return due_list


# -------------------------------------------------
# GÖREV 7 — Kaydet/Yükle (JSON)
# -------------------------------------------------
def save_to_file(books: List[Dict], path: str) -> None:
    """
    books listesini path'e JSON olarak kaydeder (UTF-8).
    """
    with open(path, "w", encoding="utf-8") as file:
        json.dump(books, file, ensure_ascii=False, indent=2)



def load_from_file(path: str) -> List[Dict]:
    """
    path'teki JSON içeriğini okuyup kitap listesi döndürür.
    Dosya yoksa boş liste döndür.
    """
    try:
        with open(path, "r", encoding="utf-8") as file:
            return json.load(file)
    except FileNotFoundError:
        return []
   


# -------------------------------------------------
# Yardımcı CLI (isteğe bağlı)
# -------------------------------------------------
def _demo():
    print("Demo: kitap ara 'an'")
    print(search_books(BOOKS, "an"))

if __name__ == "__main__":
    _demo()
