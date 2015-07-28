package kg.ash.javavi.actions;

import kg.ash.javavi.Javavi;
import org.junit.Assert;
import org.junit.Test;

public class GetClassInfoActionTest {
    
    @Test
    public void testCorrect() {
        Javavi.system.put("sources", "");
        GetClassInfoAction cia = new GetClassInfoAction();
        Assert.assertEquals("{'java.lang.Object':{'tag':'CLASSDEF','flags':'1','name':'java.lang.Object','classpath':'1','fqn':'java.lang.Object','implements':[],'ctors':[{'m':'1','d':'public java.lang.Object()'},],'fields':[],'methods':[{'n':'wait','c':'void','m':'10001','r':'void','p':['long','int',],'d':'public final void java.lang.Object.wait(long,int) throws java.lang.InterruptedException'},{'n':'wait','c':'void','m':'100010001','r':'void','p':['long',],'d':'public final native void java.lang.Object.wait(long) throws java.lang.InterruptedException'},{'n':'wait','c':'void','m':'10001','r':'void','d':'public final void java.lang.Object.wait() throws java.lang.InterruptedException'},{'n':'equals','c':'boolean','m':'1','r':'boolean','p':['java.lang.Object',],'d':'public boolean java.lang.Object.equals(java.lang.Object)'},{'n':'toString','c':'java.lang.String','m':'1','r':'java.lang.String','d':'public java.lang.String java.lang.Object.toString()'},{'n':'hashCode','c':'int','m':'100000001','r':'int','d':'public native int java.lang.Object.hashCode()'},{'n':'getClass','c':'java.lang.Class<?>','m':'100010001','r':'java.lang.Class<?>','d':'public final native java.lang.Class<?> java.lang.Object.getClass()'},{'n':'notify','c':'void','m':'100010001','r':'void','d':'public final native void java.lang.Object.notify()'},{'n':'notifyAll','c':'void','m':'100010001','r':'void','d':'public final native void java.lang.Object.notifyAll()'},],},}", cia.perform(new String[]{"-E", "java.lang.Object"}));
    }
}
