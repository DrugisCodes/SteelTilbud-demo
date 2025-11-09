import { X, Trash2 } from "lucide-react";
import { Button } from "./ui/button";
import { Product } from "./ProductCard";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "./ui/sheet";

interface ShoppingListProps {
  isOpen: boolean;
  onClose: () => void;
  products: Product[];
  onRemove: (id: string) => void;
}

const ShoppingList = ({ isOpen, onClose, products, onRemove }: ShoppingListProps) => {
  // Hjelpere for robust håndtering av tall/tekst-priser
  const isFiniteNumber = (x: unknown): x is number =>
    typeof x === "number" && Number.isFinite(x);

  const formatNumber = (n: number) =>
    n.toLocaleString("no-NO", { minimumFractionDigits: 2 });

  // Summer kun numeriske priser/sparing
  const totalPrice = products.reduce(
    (sum, p) => (isFiniteNumber(p.price) ? sum + p.price : sum),
    0
  );
  const totalSavings = products.reduce(
    (sum, p) =>
      isFiniteNumber(p.originalPrice) && isFiniteNumber(p.price)
        ? sum + (p.originalPrice - p.price)
        : sum,
    0
  );

  return (
    <Sheet open={isOpen} onOpenChange={onClose}>
      <SheetContent className="w-full sm:max-w-md bg-card border-border">
        <SheetHeader>
          <SheetTitle className="text-2xl">Din handleliste</SheetTitle>
          <SheetDescription>
            {products.length} produkter i handlelisten
          </SheetDescription>
        </SheetHeader>

        <div className="mt-6 space-y-4">
          {products.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <p className="text-muted-foreground">
                Handlelisten din er tom
              </p>
              <p className="text-sm text-muted-foreground mt-2">
                Legg til produkter ved å klikke på + knappen
              </p>
            </div>
          ) : (
            <>
              <div className="space-y-3 max-h-[60vh] overflow-y-auto pr-2">
                {products.map((product) => (
                  <div
                    key={product.id}
                    className="flex items-center gap-3 rounded-lg bg-gradient-card border border-border p-3 shadow-soft"
                  >
                    
                    <div className="flex-1 min-w-0">
                      <h4 className="font-medium text-sm line-clamp-1">
                        {product.name}
                      </h4>
                      <p className="text-xs text-muted-foreground">
                        {product.store}
                      </p>
                      {/* Vis pris-tekst for kampanjer (f.eks. "3 for 2") ellers tall med kr */}
                      <div className="text-sm text-foreground mt-1">
                        <span className="font-bold">
                          {isFiniteNumber(product.price)
                            ? `${formatNumber(product.price)} kr`
                            : typeof product.price === "string" && product.price.trim()
                            ? product.price.trim()
                            : typeof (product as any).discount === "string" && (product as any).discount.trim()
                            ? (product as any).discount.trim()
                            : "–"}
                        </span>

                        {isFiniteNumber(product.originalPrice) &&
                          isFiniteNumber(product.price) &&
                          product.originalPrice > product.price && (
                            <span className="ml-2 text-xs text-muted-foreground line-through opacity-80">
                              {formatNumber(product.originalPrice)} kr
                            </span>
                          )}
                      </div>
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => onRemove(product.id)}
                      className="h-8 w-8 text-destructive hover:bg-destructive/10"
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ))}
              </div>

              <div className="space-y-2 border-t border-border pt-4">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Totalpris:</span>
                  <span className="font-semibold">{formatNumber(totalPrice)} kr</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Spart:</span>
                  <span className="font-semibold text-deal">
                    {formatNumber(totalSavings)} kr
                  </span>
                </div>
                <div className="flex justify-between text-lg font-bold pt-2 border-t border-border">
                  <span>Totalt:</span>
                  <span>{formatNumber(totalPrice)} kr</span>
                </div>
              </div>

              <Button
                variant="outline"
                className="w-full gap-2 hover:bg-destructive/10 hover:text-destructive hover:border-destructive"
                onClick={() => products.forEach((p) => onRemove(p.id))}
              >
                <Trash2 className="h-4 w-4" />
                Tøm handlelisten
              </Button>
            </>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
};

export default ShoppingList;
