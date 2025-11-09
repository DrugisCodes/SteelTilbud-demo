import { useState, useEffect, useMemo } from "react";
import { ArrowUpDown } from "lucide-react";
import Header from "@/components/Header";
import SearchBar from "@/components/SearchBar";
import ProductCard, { Product } from "@/components/ProductCard";
import ShoppingList from "@/components/ShoppingList";
import Footer from "@/components/Footer";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { useQuery } from "@tanstack/react-query";
import { fetchProducts } from "@/lib/api";

const Index = () => {
  const { data: products = [], isLoading, isError } = useQuery<Product[]>({
    queryKey: ["products"],
    queryFn: fetchProducts,
    staleTime: 1000 * 60,
  });

  const [searchTerm, setSearchTerm] = useState("");
  const [selectedStore, setSelectedStore] = useState("Alle butikker");
  const [selectedCategory, setSelectedCategory] = useState("Alle kategorier");
  const [shoppingList, setShoppingList] = useState<string[]>([]);
  const [isShoppingListOpen, setIsShoppingListOpen] = useState(false);
  const [sortBy, setSortBy] = useState<"price" | "discount">("discount");

  // --- Hent handleliste fra localStorage ---
  useEffect(() => {
    const saved = localStorage.getItem("shoppingList");
    if (saved) setShoppingList(JSON.parse(saved));
  }, []);

  // --- Lagre handleliste til localStorage ---
  useEffect(() => {
    localStorage.setItem("shoppingList", JSON.stringify(shoppingList));
  }, [shoppingList]);

  // --- Filtrering og sortering ---
  const filteredProducts = useMemo(() => {
    let filtered = products.filter((product) => {
      const matchesSearch = product.name
        .toLowerCase()
        .includes(searchTerm.toLowerCase());
      const matchesStore =
        selectedStore === "Alle butikker" || product.store === selectedStore;
      const matchesCategory =
        selectedCategory === "Alle kategorier" ||
        product.category === selectedCategory;
      return matchesSearch && matchesStore && matchesCategory;
    });

    filtered.sort((a, b) =>
      sortBy === "price" ? a.price - b.price : b.discount - a.discount
    );

    return filtered;
  }, [products, searchTerm, selectedStore, selectedCategory, sortBy]);

  // --- Handlelistehåndtering ---
  const toggleShoppingList = (productId: string) => {
    setShoppingList((prev) => {
      if (prev.includes(productId)) {
        toast.success("Fjernet fra handlelisten");
        return prev.filter((id) => id !== productId);
      } else {
        toast.success("Lagt til i handlelisten");
        return [...prev, productId];
      }
    });
  };

  const removeFromShoppingList = (productId: string) => {
    setShoppingList((prev) => prev.filter((id) => id !== productId));
    toast.success("Fjernet fra handlelisten");
  };

  const shoppingListProducts = products.filter((p) =>
    shoppingList.includes(p.id)
  );

  const handleRefresh = () => {
    toast.success("Tilbud oppdatert!", {
      description: "Viser de nyeste tilbudene fra butikkene",
    });
  };

  const toggleSort = () => {
    setSortBy((prev) => (prev === "price" ? "discount" : "price"));
    toast.success(
      `Sorterer etter ${sortBy === "price" ? "rabatt" : "pris"}`
    );
  };

  return (
    <div className="min-h-screen flex flex-col">
      <Header
        shoppingListCount={shoppingList.length}
        onOpenShoppingList={() => setIsShoppingListOpen(true)}
      />

      <main className="flex-1 container mx-auto px-4 py-8">
        {/* Hero Section */}
        <div className="mb-8 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold mb-3">
            Sammenlign ukens mattilbud
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Sammenlign priser fra alle de største butikkene og spar penger på
            handleturen
          </p>
        </div>

        {/* Søke- og filterfelt */}
        <div className="mb-8">
          <SearchBar
            searchTerm={searchTerm}
            onSearchChange={setSearchTerm}
            selectedStore={selectedStore}
            onStoreChange={setSelectedStore}
            selectedCategory={selectedCategory}
            onCategoryChange={setSelectedCategory}
            onRefresh={handleRefresh}
          />
        </div>

        {/* Resultatoverskrift */}
        <div className="mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <p className="text-sm text-muted-foreground">
            Viser{" "}
            <span className="font-semibold text-foreground">
              {filteredProducts.length}
            </span>{" "}
            tilbud
          </p>
          <Button
            variant="outline"
            onClick={toggleSort}
            className="gap-2 hover:bg-primary/10"
          >
            <ArrowUpDown className="h-4 w-4" />
            Sorter etter {sortBy === "price" ? "pris" : "rabatt"}
          </Button>
        </div>

        {/* Produktgrid */}
        {isLoading ? (
          <div className="text-center py-16">
            <p className="text-muted-foreground text-lg">Laster tilbud…</p>
          </div>
        ) : isError ? (
          <div className="text-center py-16">
            <p className="text-muted-foreground text-lg">
              Kunne ikke hente tilbud fra serveren
            </p>
            <p className="text-sm text-muted-foreground mt-2">
              {import.meta.env.MODE === "development"
                ? "Sjekk at API-et kjører lokalt (http://localhost:3001)"
                : "Prøv å laste siden på nytt, eller kom tilbake senere."}
            </p>
          </div>
        ) : filteredProducts.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-muted-foreground text-lg">
              Ingen produkter funnet
            </p>
            <p className="text-sm text-muted-foreground mt-2">
              Prøv å endre søkekriteriene
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 animate-in">
            {filteredProducts.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                isInList={shoppingList.includes(product.id)}
                onToggle={() => toggleShoppingList(product.id)}
              />
            ))}
          </div>
        )}
      </main>

      <Footer />

      {/* Handlelistepanel */}
      <ShoppingList
        isOpen={isShoppingListOpen}
        onClose={() => setIsShoppingListOpen(false)}
        products={shoppingListProducts}
        onRemove={removeFromShoppingList}
      />
    </div>
  );
};

export default Index;
