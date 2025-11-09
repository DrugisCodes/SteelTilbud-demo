import { ShoppingCart } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "./ui/button";

interface HeaderProps {
  shoppingListCount: number;
  onOpenShoppingList: () => void;
}

const Header = ({ shoppingListCount, onOpenShoppingList }: HeaderProps) => {
  return (
    <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur-sm shadow-medium">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Link to="/" aria-label="Gå til forsiden" className="flex items-center gap-3 group/link">
            {/* Byttet ut ST med logo-bilde */}
            <img
              src="/favicon.png"
              alt="SteelTilbud logo"
              className="h-16 w-16 rounded-xl shadow-soft object-cover transition-transform group-hover/link:scale-[1.03]"
            />

            <div>
              <h1 className="text-2xl font-bold tracking-tight group-hover/link:text-primary transition-colors">SteelTilbud</h1>
              <p className="text-xs text-muted-foreground">Ukens beste mattilbud</p>
            </div>
          </Link>

          
          <Button
            variant="outline"
            size="lg"
            onClick={onOpenShoppingList}
            className="relative gap-2 hover:bg-primary/10 transition-all"
          >
            <ShoppingCart className="h-5 w-5" />
            <span className="hidden sm:inline">Handleliste</span>
            {shoppingListCount > 0 && (
              <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-deal text-xs font-bold text-deal-foreground">
                {shoppingListCount}
              </span>
            )}
          </Button>
        </div>
      </div>
    </header>
  );
};

export default Header;
