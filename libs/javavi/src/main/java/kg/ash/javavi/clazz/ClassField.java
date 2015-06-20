package kg.ash.javavi.clazz;

import java.util.Objects;

public class ClassField {

    private String name;
    private int modifiers;
    private String typeName;

    public void setName(String name) {
        this.name = name;
    }
    
    public String getName() {
        return name;
    }

    public void setModifiers(int modifiers) {
        this.modifiers = modifiers;
    }

    public int getModifiers() {
        return modifiers;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getTypeName() {
        return typeName;
    }

    @Override
    public boolean equals( Object obj ) {
        if ( obj == null ) {
            return false;
        }
        if ( getClass() != obj.getClass() ) {
            return false;
        }
        final ClassField other = ( ClassField ) obj;
        if ( !Objects.equals( this.name, other.name ) && ( this.name == null || !this.name.equals( other.name ) ) ) {
            return false;
        }
        return this.typeName == other.typeName || (this.typeName != null && this.typeName.equals( other.typeName ));
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 17 * hash + ( this.name != null ? this.name.hashCode() : 0 );
        hash = 17 * hash + ( this.typeName != null ? this.typeName.hashCode() : 0 );
        return hash;
    }
}
